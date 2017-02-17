//////////////////////////////////////////////////////////////////////////////////
//Filename: TRAFFIC.v
//Author: Wenzhengxing
//Description: Drive the traffic system
//Called by: MAIN.v
//Revision History: 2015-08-17
//Revision: 0.1
//Email: 1308950671@qq.com
//Company: None
//Copyright(c) 2015, Person, All right reserved 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps   

module TRAFFIC(CLK, FLK_CLK, ONLINE, RST, SET, Cm, Cc, PQm, PQc, BUSY,
               MR, MY, MG, CR, CY, CG, MCOUTH, MCOUTL,
					CCOUTH, CCOUTL, ONLINELED);

    input CLK, FLK_CLK, ONLINE, RST, SET;              //module input
    input Cm, Cc, PQm, PQc, BUSY;             //module input
	 output MR, MY, MG, CR, CY, CG, ONLINELED; //module output
	 output [3:0] MCOUTH, MCOUTL, CCOUTH, CCOUTL;  //counting output
    
    reg [3:0] MCOUTH, MCOUTL, CCOUTH, CCOUTL;
	 reg fMR, fMY, fMG, fCR, fCY, fCG;
	 reg filker1 = 0, filker2 = 0;
    reg [1:0] state = 2'b11;                  //main state flag
    reg [1:0] next_state = 2'b00;             //next main state flag
    reg fzero = 0;                            //counting flag
	 reg [1:0] cstate1 = 2'b00;
	 reg [1:0] fpq = 2'b00;
    reg fpq_handle = 0;
	 reg freset = 0;                            //flag for reset
    
	 //generate the light 
	 assign MR = filker2 ? FLK_CLK : fMR;
	 assign MY = filker1 ? FLK_CLK : fMY;
	 assign MG = fMG;
	 assign CR = filker1 ? FLK_CLK : fCR;
	 assign CY = filker2 ? FLK_CLK : fCY;
	 assign CG = fCG;
	 
	 
    //definition of state for main FSM
    parameter MST1 = 2'b11,
	           MST2 = 2'b00,
			     MST3 = 2'b10,
			     MST4 = 2'b01;

    //definition of state for the traffic state
    parameter ST1 = 2'b00,
	           ST2 = 2'b01,
			     ST3 = 2'b10,
			     ST4 = 2'b11;


    //define the traffic light's state 
    parameter ON = 1'b1, OFF = 1'b0;

 
    assign ONLINELED = ONLINE; 
	 
    
    //generate the people request 
	 always @(PQm or PQc or fpq_handle) begin
	     if ((state == MST2 && {PQm, PQc} == 2'b10) 
		      || (state == MST3 && {PQm, PQc} == 2'b10)
				|| (state == MST4 && {PQm, PQc} == 2'b01))
		      fpq = {PQm, PQc};
		  else  begin
		      if (!fpq_handle)
		          fpq = fpq;
		      else 
				    fpq = 0;
		  end
	 end
	 
    
    //generate the next main state
    always @(Cm or Cc) begin
            next_state = {Cm, Cc};
    end
    
	 
    //main FSM
    always @(posedge CLK) begin
            if (!SET) ;                    //do nothing 
            else begin
                case (state)
                MST1:  
					     mst1_work;
                MST2:
					     mst2_work;
                MST3:
					     mst3_work;
                MST4:
					     mst4_work;
                endcase
            end
        end     //end if (ONLINE)



//task of countering      
task counter_tostate;

begin
   if (CCOUTH == 0 && CCOUTL==1) begin
		  fzero <= 0;
		  {CCOUTH, CCOUTL} <= {4'b0000, 4'b0000};
	end
	else if (CCOUTL == 0) begin
		  CCOUTL <= 4'b1001;
		  CCOUTH <= CCOUTH - 1'b1;
	end
	else begin
		  CCOUTL <= CCOUTL - 1'b1;
   end
	
   if (MCOUTH == 0 && MCOUTL==1) begin
		  fzero <= 0;
		  {MCOUTH, MCOUTL} <= {4'b0000, 4'b0000};
	end
	else if (MCOUTL == 0) begin
		  MCOUTL <= 4'b1001;
		  MCOUTH <= MCOUTH - 1'b1;
	end
	else begin
		  MCOUTL <= MCOUTL - 1'b1;
   end
end
endtask


//task of countering        
task counter_no_state;
begin
    if (CCOUTH == 0 && CCOUTL==1) begin
		  fzero <= 0;
		  {CCOUTH, CCOUTL} <= {4'b0000, 4'b0000};
		  {MCOUTH, MCOUTL} <= {4'b0000, 4'b0000};
	end
	else if (CCOUTL == 0) begin
		  CCOUTL <= 4'b1001;
		  CCOUTH <= CCOUTH - 1'b1;
		  MCOUTL <= 4'b1001;
		  MCOUTH <= MCOUTH - 1'b1;
	end
	else begin
		  CCOUTL <= CCOUTL - 1'b1;
		  MCOUTL <= MCOUTL - 1'b1;
    end
end
endtask


//MST1 task
task mst1_work;
    if (!BUSY) begin
        case(cstate1)
        ST1:
            if (fzero == 0) begin	
                //	1			
					 if (ONLINE) begin
                  {CCOUTH, CCOUTL} <= {4'b0001, 4'b0101};
                  {MCOUTH, MCOUTL} <= {4'b0001, 4'b0101};
                  fzero <= 1;
                  {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b001100;
					 end  
					 //    1
					 else begin
                    {CCOUTH, CCOUTL} <= {4'b0001, 4'b1000};
                    {MCOUTH, MCOUTL} <= {4'b0001, 4'b0101};
                     fzero <= 1;
                    {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b001100;
					     freset <= 1;
					 end
            end
            else begin
				    //  2
				    if(ONLINE)
                    counter_tostate;
					 //  2
					 else begin
				      if (freset && RST) ;     //reset
					   else begin
					     freset <= 0;
                    counter_tostate;
                    if ((CCOUTH == 0 && CCOUTL==1) || (MCOUTH == 0 && MCOUTL==1))
					     begin
					         cstate1 <= ST2;
					     end
					     else ;
					  end
				 end
				end
        ST2:
            if (fzero == 0) begin
                {CCOUTH, CCOUTL} <= {4'b0000, 4'b0010};
                {MCOUTH, MCOUTL} <= {4'b0000, 4'b0010};
                fzero <= 1;
                {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b010100;
					 filker1 <= 1;
            end
            else begin
                counter_tostate;
                if ((CCOUTH == 0 && CCOUTL==1) || (MCOUTH == 0 && MCOUTL==1))
					 begin
					     cstate1 <= ST3;
						  filker1 <= 0;
					 end
					 else ;
					 fpq_handle <= 0;
                state <= (CCOUTL == 1) && (next_state == MST4)
                         ? next_state : state;
				end
        ST3:
            if (fzero == 0) begin
                {CCOUTH, CCOUTL} <= {4'b0001, 4'b0101};
                {MCOUTH, MCOUTL} <= {4'b0001, 4'b1000};
                fzero <= 1;
                {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b100001;
            end
            else begin
                counter_tostate;
                if ((CCOUTH == 0 && CCOUTL==1) || (MCOUTH == 0 && MCOUTL==1))
					 begin
					     cstate1 <= ST4;
					 end
					 else ;
				end
        ST4:
            if (fzero == 0) begin
                {CCOUTH, CCOUTL} <= {4'b0000, 4'b0010};
                {MCOUTH, MCOUTL} <= {4'b0000, 4'b0010};
                fzero <= 1;
                {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b100010;
					 filker2 <= 1;
            end
            else begin
                counter_tostate;
                if ((CCOUTH == 0 && CCOUTL==1) || (MCOUTH == 0 && MCOUTL==1))
					 begin
					     cstate1 <= ST1;
						  filker2 <= 0;
					 end
					 else ;
					 fpq_handle <= 0;
                state <= (CCOUTL == 1) && (next_state == MST2 || 
                         next_state == MST3 || next_state == MST1)
                         ? next_state : state;
            end
        endcase
    end
    else begin
        case(cstate1)
        ST1:
            if (fzero == 0) begin
                {CCOUTH, CCOUTL} <= {4'b0010, 4'b0000};
                {MCOUTH, MCOUTL} <= {4'b0001, 4'b0101};
                fzero <= 1;
                {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b001100;
            end
            else begin
                counter_tostate;
                if ((CCOUTH == 0 && CCOUTL==1) || (MCOUTH == 0 && MCOUTL==1))
					     cstate1 <= ST2;
					 else ;
				end
        ST2:
            if (fzero == 0) begin
                {CCOUTH, CCOUTL} <= {4'b0000, 4'b0100};
                {MCOUTH, MCOUTL} <= {4'b0000, 4'b0100};
                fzero <= 1;
                {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b010100;
					 filker1 <= 1;
            end
            else begin
                counter_tostate;
                if ((CCOUTH == 0 && CCOUTL==1) || (MCOUTH == 0 && MCOUTL==1)) begin
					     filker1 <= 0;
					     cstate1 <= ST3;
					 end
					 else ;
                state <= (CCOUTL == 1) && (next_state == MST4)
                         ? next_state : state;
				end
        ST3:
            if (fzero == 0) begin
                {CCOUTH, CCOUTL} <= {4'b0000, 4'b0111};
                {MCOUTH, MCOUTL} <= {4'b0001, 4'b0010};
                fzero <= 1;
                {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b100001;
            end
            else begin
                counter_tostate;
                if ((CCOUTH == 0 && CCOUTL==1) || (MCOUTH == 0 && MCOUTL==1))
					     cstate1 <= ST4;
					 else ;
				end
        ST4:
            if (fzero == 0) begin
                {CCOUTH, CCOUTL} <= {4'b0000, 4'b0100};
                {MCOUTH, MCOUTL} <= {4'b0000, 4'b0100};
                fzero <= 1;
                {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b100010;
					 filker2 <= 1;
            end
            else begin
                counter_tostate;
                if ((CCOUTH == 0 && CCOUTL==1) || (MCOUTH == 0 && MCOUTL==1)) begin
					     filker2 <= 0;
					     cstate1 <= ST1;
					 end
					 else ;
                state <= (CCOUTL == 1) && (next_state == MST2 || 
                         next_state == MST3 || next_state == MST1)
                         ? next_state : state;
            end
        endcase
    end
endtask


//MST2 task
task mst2_work;
   //3
   if (ONLINE && fzero == 0) begin
                  {CCOUTH, CCOUTL} <= {4'b0001, 4'b0101};
                  {MCOUTH, MCOUTL} <= {4'b0001, 4'b0101};
                  fzero <= 1;
                  {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b001100;
                  {state, cstate1} <= {MST1, ST1};
	end
	//3   modify mst3_work like this
	
	else begin
    if (fpq == 2'b10 && fzero == 0) begin
		{CCOUTH, CCOUTL} <= {4'b0000, 4'b0010};
		{MCOUTH, MCOUTL} <= {4'b0000, 4'b0010};
		fzero <= 1;
		filker1 <= 1;
      {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b010100;
		state <= MST1;
		cstate1 <= ST2;
		fpq_handle <= 1;
	 end 
    else if (state != next_state && fzero == 0) begin
        if (next_state == MST1) 
            {state, cstate1} <= {next_state, ST2};
        else if (next_state == MST3)
            state <= next_state;
        else if (next_state == MST4) begin
			{CCOUTH, CCOUTL} <= {4'b0000, 4'b0010};
			{MCOUTH, MCOUTL} <= {4'b0000, 4'b0010};
			fzero <= 1;
		   filker1 <= 1;
         {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b010100;
			state <= MST1;
			cstate1 <= ST2;
        end
    end
    else begin
        if (fzero == 0) begin
		      if (!RST) begin
                {CCOUTH, CCOUTL} <= {4'b0001, 4'b0101};
                {MCOUTH, MCOUTL} <= {4'b0001, 4'b0101};
                fzero <= 1;
                {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b001100;
				end
				else begin
                {fzero, state, cstate1} <= {1'b1, MST1, ST1};
                {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b001100;
                {CCOUTH, CCOUTL} <= {4'b0001, 4'b1000};
					 {MCOUTH, MCOUTL} <= {4'b0001, 4'b0101};
					 {filker1, filker2} <= 2'b00;
					 freset <= 1;
				end
        end
        else begin
                counter_no_state;
	     end
    end
 end
endtask


//MST3 task
task mst3_work;
    if (fpq == 2'b10 && fzero == 0) begin
		  {CCOUTH, CCOUTL} <= {4'b0000, 4'b0010};
		  {MCOUTH, MCOUTL} <= {4'b0000, 4'b0010};
        fzero <= 1;
        {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b010100;
        state <= MST1;
        cstate1 <= ST2;
		  fpq_handle <= 1;
		  filker1 <= 1;
    end 
    else if (state != next_state && fzero == 0) begin
        if (next_state == MST1) 
            {state, cstate1} <= {next_state, ST2};
        else if (next_state == MST2)
            state <= next_state;
        else if (next_state == MST4) begin
		      {CCOUTH, CCOUTL} <= {4'b0000, 4'b0010};
		      {MCOUTH, MCOUTL} <= {4'b0000, 4'b0010};
			   fzero <= 1;
            {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b010100;
			   state <= MST1;
			   filker1 <= 1;
			   cstate1 <= ST2;
        end
    end
    else begin
        if (fzero == 0) begin
		      if (!RST) begin
                {CCOUTH, CCOUTL} <= {4'b0001, 4'b0100};
                {MCOUTH, MCOUTL} <= {4'b0001, 4'b0100};
                fzero <= 1;
                {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b001100;
				 end
				 else begin
                {fzero, state, cstate1} <= {1'b1, MST1, ST1};
                {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b001100;
                {CCOUTH, CCOUTL} <= {4'b0001, 4'b1000};
					 {MCOUTH, MCOUTL} <= {4'b0001, 4'b0101};
					 {filker1, filker2} <= 2'b00;
					 freset <= 1;
				  end
        end
        else begin
                counter_no_state;
		  end
		end
endtask


//MST4 task
task mst4_work;
   //4
   if (ONLINE && fzero == 0) begin
                  {CCOUTH, CCOUTL} <= {4'b0000, 4'b0010};
                  {MCOUTH, MCOUTL} <= {4'b0000, 4'b0010};
                  fzero <= 1;
                  {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b100010;
                  {state, cstate1} <= {MST1, ST4};
		            filker2 <= 1;
	end
	//4
	else begin
    if (fpq == 2'b01 && fzero == 0) begin
		  {CCOUTH, CCOUTL} <= {4'b0000, 4'b0010};
		  {MCOUTH, MCOUTL} <= {4'b0000, 4'b0010};
        fzero <= 1;
        {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b100010;
        state <= MST1;
        cstate1 <= ST4;
		  fpq_handle <= 1;
		  filker2 <= 1;
    end 
    else if (state != next_state && fzero == 0) begin
		  {CCOUTH, CCOUTL} <= {4'b0000, 4'b0010};
		  {MCOUTH, MCOUTL} <= {4'b0000, 4'b0010};
        fzero <= 1;
        {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b100010;
		  state <= MST1;
		  cstate1 <= ST4;
		  filker2 <= 1;
    end
    else begin
        if (fzero == 0) begin
		      if (!RST) begin
                {CCOUTH, CCOUTL} <= {4'b0001, 4'b0100};
                {MCOUTH, MCOUTL} <= {4'b0001, 4'b0100};
                fzero <= 1;
                {fMR, fMY, fMG, fCR, fCY, fCG} <= 6'b100001;
				end
				else begin
				    state <= MST1;
					 cstate1 <= ST4;
				end
        end
        else begin
            counter_no_state;
		  end
	 end
end
endtask

endmodule




















