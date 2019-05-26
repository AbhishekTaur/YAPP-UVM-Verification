/*******************************************************************************

  Copyright (c) 2011 Cadence Design Systems, Inc. All rights reserved worldwide.

  This software is licensed under the Apache license, version 2.0 ("License").
  This software may only be used in compliance with the terms of the License.
  Any other use is strictly prohibited. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

        The software distributed under the License is provided  "AS IS" WITHOUT
  WARRANTY, EXPRESS OR IMPLIED, OF ANY KIND, INCLUDING, WITHOUT LIMITATION ANY
  WARRANTY AS TO PERFORMANCE, NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS
  FOR ANY PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE RESULTS AND PERFORMANCE
  OF THE PRODUCT IS ASSUMED BY YOU.  TO THE MAXIMUM EXTENT PERMITTED BY LAW,
  IN NO EVENT SHALL CADENCE BE LIABLE TO YOU OR ANY THIRD PARTY FOR ANY
  INCIDENTAL, INDIRECT, SPECIAL OR CONSEQUENTIAL DAMAGES, OR ANY OTHER DAMAGES,
  INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS PROFITS, BUSINESS
  INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR OTHER PECUNIARY LOSS ARISING
  OUT OF THE USE OFTHIS SOFTWARE.

        See the License terms for the specific language governing the permissions
  and limitations under the License.

*******************************************************************************/

package phase_watcher_pkg;
    import uvm_pkg::*;

    int streams[string];

    task automatic main_process;
        static uvm_domain domains[string];
        static uvm_phase common = uvm_domain::get_common_domain();
        static uvm_phase p = uvm_end_of_elaboration_phase::get();
        static uvm_phase run = uvm_run_phase::get();

        static uvm_phase run_phases[$] = '{
            uvm_pre_reset_phase::get(),
            uvm_reset_phase::get(),
            uvm_post_reset_phase::get(),
            uvm_pre_configure_phase::get(),
            uvm_configure_phase::get(),
            uvm_post_configure_phase::get(),
            uvm_pre_main_phase::get(),
            uvm_main_phase::get(),
            uvm_post_main_phase::get(),
            uvm_pre_shutdown_phase::get(),
            uvm_shutdown_phase::get(),
            uvm_post_shutdown_phase::get()
        };

        p = common.find(p);
        run = common.find(run);

        fork
            do_phase_watcher(common, run);
        join_none

        p.wait_for_state(UVM_PHASE_DORMANT, UVM_NE);
        uvm_domain::get_domains(domains);

        foreach (domains[i]) begin
            uvm_phase d;
            d = domains[i];
            foreach(run_phases[j]) begin
                uvm_phase ph;
                ph = d.find(run_phases[j]);
                if(ph != null) begin
                    fork begin
                            uvm_phase thedomain = d;
                            uvm_phase thephase = ph;
                            do_phase_watcher(d, ph);
                        end join_none
                end
            end
        end

    endtask

    task automatic do_phase_watcher(uvm_phase domain, uvm_phase phase);
        uvm_phase_state s;
        integer stream, txh=-1, pred=-1, ev;
        uvm_phase_state state;
        string fullphase = {"uvm_phases.",domain.get_full_name()};

        s = phase.get_state();

        if(!streams.exists(phase.get_full_name())) 
            stream = $sdi_create_fiber(domain.get_name(), "TVM", "uvm_phases");

        forever begin
            phase.wait_for_state(s, UVM_NE);
            s = phase.get_state(); 
            uvm_report_info("PHASE-TRACER",$sformatf("%s %s",s.name(),phase.get_full_name()),UVM_DEBUG);
            case(s)
                UVM_PHASE_ENDED: $sdi_end_transaction(txh);
                UVM_PHASE_JUMPING: 
                begin
                    txh=$sdi_transaction("Event", stream, {uvm_string_to_bits(phase.get_name()), " jumping"});
                    $sdi_end_transaction(txh);
                end
                UVM_PHASE_STARTED: txh = $sdi_transaction("Begin_No_Parent", stream, uvm_string_to_bits(phase.get_name()));
            endcase
        end
    endtask

    bit package_initialized = initialize_the_package();
    function bit initialize_the_package();
        uvm_report_info("PHASE-TRACER","simvision phase tracer",UVM_HIGH);
        fork
            main_process;
        join_none
        return 1;
    endfunction
endpackage

import phase_watcher_pkg::initialize_the_package;
