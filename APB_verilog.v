module apb_protocol(clk,rst,pselx,penable,pwrite,paddr,pwdata,prdata,pready,pslverror);
input clk,rst,pselx,penable,pwrite;
input [31:0] paddr;
input [31:0] pwdata;
output reg [31:0] prdata;
output pready;
output reg pslverror;
reg busy=0;
reg [31:0]mem[2047:0];
reg[1:0] p_state, n_state;
parameter IDLE=0;
parameter SETUP=1;
parameter ACCESS=2;
assign pready =!busy;
always @(posedge clk,negedge rst)//async rst
if(!rst)
begin
prdata<=0;
p_state<=IDLE;
for (integer i=0;i<2048; i=i+1)
mem[i]<=0;
end
else
p_state<=n_state;
always @(pready,penable,pselx,pwrite)
// begin
case(p_state)

IDLE:
begin
if(pselx==0)
n_state= IDLE;
else
n_state= SETUP;
end
SETUP:
begin
if(pselx==1 && penable==0)
n_state= SETUP;
else if(pselx==1 && penable==1)
n_state= ACCESS;
else
n_state= IDLE;
end
ACCESS:
begin
if (pselx==1 && penable==1)
n_state=ACCESS;
else if( pselx==1 && penable==0)
n_state=SETUP;
else
n_state=IDLE;
end
endcase
always @(pready,pselx,pwrite,penable,p_state)
begin
if( p_state==ACCESS)
begin
if(pwrite==1 && paddr>=0 && paddr<=2047)
mem[paddr]=pwdata;
else if(pwrite==0 && paddr>=0 && paddr<=2047)
prdata= mem[paddr];
else
pslverror=1;
end
else
pslverror=0;
end
endmodule 