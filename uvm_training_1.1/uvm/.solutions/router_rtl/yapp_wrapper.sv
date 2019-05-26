module yapp_wrapper (input clock, 
            input reset,
            output error,
            yapp_if in0,
            channel_if ch0,
            channel_if ch1,
            channel_if ch2,
            hbus_if hif );

yapp_router router  (.clock,                              
                    .reset,                            
                    .error,

                    // Input channel
                    .in_data(in0.data),                           
                    .in_data_vld(in0.data_vld),                     
                    .in_suspend(in0.suspend),

                    // Output Channels
                    .data_0(ch0.data),  //Channel 0
                    .data_vld_0(ch0.data_vld), 
                    .suspend_0(ch0.suspend), 
                    .data_1(ch1.data),  //Channel 1
                    .data_vld_1(ch1.data_vld), 
                    .suspend_1(ch1.suspend), 
                    .data_2(ch2.data),  //Channel 2
                    .data_vld_2(ch2.data_vld),
                    .suspend_2(ch2.suspend),
     
                    // Host Interface Signals
                    .haddr(hif.haddr),
                    .hdata(hif.hdata_w),
                    .hen(hif.hen),
                    .hwr_rd(hif.hwr_rd));                            

endmodule : yapp_wrapper
