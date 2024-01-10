/*------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Copyright (c) 2016, Loongson Technology Corporation Limited.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of Loongson Technology Corporation Limited nor the names of 
its contributors may be used to endorse or promote products derived from this 
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL LOONGSON TECHNOLOGY CORPORATION LIMITED BE LIABLE
TO ANY PARTY FOR DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

module cpu_axi_interface
(
    input         clk,
    input         resetn, 

    //inst sram-like 
    input         inst_req     ,
    input         inst_wr      ,
    input  [1 :0] inst_size    ,
    input  [31:0] inst_addr    ,
    input  [31:0] inst_wdata   ,
    output [31:0] inst_rdata   ,
    output        inst_addr_ok ,
    output        inst_data_ok ,
    
    //data sram-like 
    input         data_req     ,
    input         data_wr      ,
    input  [1 :0] data_size    ,
    input  [31:0] data_addr    ,
    input  [31:0] data_wdata   ,
    output [31:0] data_rdata   ,
    output        data_addr_ok ,
    output        data_data_ok ,

    //axi
    //ar
    output [3 :0] arid         ,
    output [31:0] araddr       ,
    output [7 :0] arlen        ,
    output [2 :0] arsize       ,
    output [1 :0] arburst      ,
    output [1 :0] arlock        ,
    output [3 :0] arcache      ,
    output [2 :0] arprot       ,
    output        arvalid      ,
    input         arready      ,
    //r           
    input  [3 :0] rid          ,
    input  [31:0] rdata        ,
    input  [1 :0] rresp        ,
    input         rlast        ,
    input         rvalid       ,
    output        rready       ,
    //aw          
    output [3 :0] awid         ,
    output [31:0] awaddr       ,
    output [7 :0] awlen        ,
    output [2 :0] awsize       ,
    output [1 :0] awburst      ,
    output [1 :0] awlock       ,
    output [3 :0] awcache      ,
    output [2 :0] awprot       ,
    output        awvalid      ,
    input         awready      ,
    //w          
    output [3 :0] wid          ,
    output [31:0] wdata        ,
    output [3 :0] wstrb        ,
    output        wlast        ,
    output        wvalid       ,
    input         wready       ,
    //b           
    input  [3 :0] bid          ,
    input  [1 :0] bresp        ,
    input         bvalid       ,
    output        bready       
);
//addr
reg do_req;
reg do_req_or; //req is inst or data;1:data,0:inst
reg        do_wr_r;
reg [1 :0] do_size_r;
reg [31:0] do_addr_r;
reg [31:0] do_wdata_r;
wire data_back;

wire rst;
assign rst = ~resetn;
reg arvalid_r;  //1取指或读数据，0握手成功
reg read_sel;  //0取指，1读数据

always @(posedge clk) 
begin
    arvalid_r <= rst ? 1'b0 :
                 arvalid & arready ? 1'b0 :
                 inst_req | (data_req & ~data_wr) ? 1'b1 : arvalid_r;
    read_sel <= rst ? 1'b0 :
                data_req & ~data_wr ? 1'b1 :
                inst_req ? 1'b0 : read_sel;
end

reg write_req;  //发出写请求整个期间
reg waddr_rcv;  //写地址握手成功后
reg wdata_rcv;  //写数据握手成功后
wire write_finish; 
always @(posedge clk) 
begin
    write_req <= rst                ? 1'b0 :
                 data_req & data_wr ? 1'b1 :
                 write_finish       ? 1'b0 : write_req;
    waddr_rcv <= rst               ? 1'b0 :
                 awvalid & awready ? 1'b1 :
                 write_finish      ? 1'b0 : waddr_rcv;
    wdata_rcv <= rst                     ? 1'b0 :
                 wvalid & wready & wlast ? 1'b1 :
                 write_finish            ? 1'b0 : wdata_rcv;
end
assign write_finish = waddr_rcv & wdata_rcv & (bvalid & bready);
/*always @(posedge clk)
begin
    do_req     <= !resetn                       ? 1'b0 : 
                  (inst_req||data_req)&&!do_req ? 1'b1 :
                  data_back                     ? 1'b0 : do_req;
    do_req_or  <= !resetn ? 1'b0 : 
                  !do_req ? data_req : do_req_or;

    do_wr_r    <= data_req&&data_addr_ok ? data_wr :
                  inst_req&&inst_addr_ok ? inst_wr : do_wr_r;
    do_size_r  <= data_req&&data_addr_ok ? data_size :
                  inst_req&&inst_addr_ok ? inst_size : do_size_r;
    do_addr_r  <= data_req&&data_addr_ok ? data_addr :
                  inst_req&&inst_addr_ok ? inst_addr : do_addr_r;
    do_wdata_r <= data_req&&data_addr_ok ? data_wdata :
                  inst_req&&inst_addr_ok ? inst_wdata :do_wdata_r;
end*/

//sram-like
assign inst_data_ok = rvalid & (rid==4'd0);
assign inst_addr_ok = ~read_sel & arvalid & arready;
assign inst_rdata   = rdata;

assign data_data_ok = rvalid & (rid==4'd1) | write_finish;
assign data_addr_ok = read_sel & arvalid & arready | data_req & waddr_rcv & wdata_rcv;
assign data_rdata   = rdata;

//---axi
/*reg addr_rcv;
reg wdata_rcv;

assign data_back = addr_rcv && (rvalid&&rready||bvalid&&bready);
always @(posedge clk)
begin
    addr_rcv  <= !resetn          ? 1'b0 :
                 arvalid&&arready ? 1'b1 :
                 awvalid&&awready ? 1'b1 :
                 data_back        ? 1'b0 : addr_rcv;
    wdata_rcv <= !resetn        ? 1'b0 :
                 wvalid&&wready ? 1'b1 :
                 data_back      ? 1'b0 : wdata_rcv;
end*/
//ar
assign arid    = read_sel ? 4'd1 : 4'd0;
assign araddr  = read_sel ? data_addr : inst_addr;
assign arlen   = 8'd0;
assign arsize  = read_sel ? data_size : inst_size;
assign arburst = 2'd0;
assign arlock  = 2'd0;
assign arcache = 4'd0;
assign arprot  = 3'd0;
assign arvalid = arvalid_r;
//r
assign rready  = 1'b1;

//aw
assign awid    = 4'd0;
assign awaddr  = data_addr;
assign awlen   = 8'd0;
assign awsize  = data_size;
assign awburst = 2'd0;
assign awlock  = 2'd0;
assign awcache = 4'd0;
assign awprot  = 3'd0;
assign awvalid = write_req & ~waddr_rcv;
//w
assign wid    = 4'd0;
assign wdata  = data_wdata;
assign wstrb  = awsize==2'd0 ? 4'b0001<<awaddr[1:0] :
                awsize==2'd1 ? 4'b0011<<awaddr[1:0] : 4'b1111;
assign wlast  = 1'd1;
assign wvalid = write_req & ~wdata_rcv;
//b
assign bready  = 1'b1;

endmodule

