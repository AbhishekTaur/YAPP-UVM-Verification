module four_packet_test;
import four_packet_classes::*;

fourpacket pkt4_1,pkt4_2;
packet pktone, pkttwo;

initial begin
  pkt4_1 = new("pkt4_one");  
  pktone = new("pone",1);
  pktone.target = 0;
  pktone.data = 5;
  pktone.clone(pkttwo);
  pktone.print();
  pkttwo.print();
  assert(pktone.compare(pkttwo));
  pkt4_1 = new("pkt4_one");  
  assert(pkt4_1.randomize());
  pkt4_1.deep_clone(pkt4_2);
  pkt4_2.deep_print();
  assert(pkt4_1.deep_compare(pkt4_2));
end

endmodule
   

