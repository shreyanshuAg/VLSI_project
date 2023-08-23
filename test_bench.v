module tb();
reg clk,rst,pselx,penable,pwrite;
reg [31:0] paddr;
reg [31:0] pwdata;
wire [31:0] prdata;
wire pready,pslverror;
apb_protocol dut(clk,rst,pselx,penable,pwrite,paddr,pwdata,prdata,pready,pslverror);
always #5 clk=!clk;
initial
begin
clk=0;rst=0;pselx=0;
penable=0;
pwrite=0;
#7;rst=1;
$monitor("t=%d,pselx=%b,penable=%b,pwrite=%b,paddr=%d,pwdata=%d,prdata=%d,pready=%b,pslverror=%b
",$time,pselx,penable,pwrite,paddr,pwdata,prdata,pready,pslverror);
$dumpfile("dump.vcd");
$dumpvars(0,tb);
#1000 $finish;
end
task write(integer num,i_addr);
repeat(num)
begin
pselx=1;
paddr=i_addr;
pwdata=$random;
i_addr=i_addr+1;
pwrite=1;
@(negedge clk)
penable=1;
@(negedge clk)
wait(pready==1);
penable=0;
end
endtask
task read(integer num,i_addr);
repeat(num)
begin
pselx=1;
paddr=i_addr;
i_addr=i_addr+1;
pwrite=0;
@(negedge clk)
penable=1;
@(negedge clk)
wait(pready==1);
penable=0;
end
endtask
initial
begin
write(20,1215);
read(14,1221);
write(5,2047);
read(3,2047);
end
endmodule 