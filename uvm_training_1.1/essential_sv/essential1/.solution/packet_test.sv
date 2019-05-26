module packet_test;
import packet_classes::*;

base parray [15:0];
packet p;
psingle ps;
pbroadcast pb;
pmulticast pm;
string str;

initial begin
  for (int i = 0;i<15;i++) begin
    str.itoa(i);
    randcase
     1:begin : single_packet
       ps = new({"ps",str},1); 
       assert(ps.randomize());
       parray[i] = ps;
       end
     1:begin : multicast_packet
       pb = new({"pb",str},2);
       assert(pb.randomize());
       parray[i] = pb;
       end
     1:begin : broadcast_packet
       pm = new({"pm",str},3);
       assert(pm.randomize());
       parray[i] = pm;
       end
     endcase
  end
  for (int i = 0;i<15;i++) 
    parray[i].print(BIN);
end

endmodule
   

