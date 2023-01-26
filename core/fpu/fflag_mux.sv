/*
 * Copyright © 2019-2023 Yuhui Gao, Lesley Shannon
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Initial code developed under the supervision of Dr. Lesley Shannon,
 * Reconfigurable Computing Lab, Simon Fraser University.
 *
 * Author(s):
 *             Yuhui Gao <yuhuig@sfu.ca>
 */

module fflag_mux
    import fpu_types::*;
(
    input clk,
    input fflags_writeback_t unit_fflag_wb_packet,
    input fflags_writeback_t fp_unit_fflag_wb_packet,
    input fcsr_fifo_data_t oldest_fp_issued_fifo_data_in,
    input logic oldest_fp_issued_fifo_pop,
    //output logic fflags_update,
    output logic [4:0] fflags
);

    (* ram_style = "distributed" *)
    logic [4:0] unit_fflags_table [MAX_IDS];
    (* ram_style = "distributed" *)
    logic [4:0] fp_unit_fflags_table [MAX_IDS];

    always_ff @ (posedge clk) begin
        if (unit_fflag_wb_packet.valid)
            unit_fflags_table[unit_fflag_wb_packet.id] <= unit_fflag_wb_packet.fflags;

        if (fp_unit_fflag_wb_packet.valid)
            fp_unit_fflags_table[fp_unit_fflag_wb_packet.id] <= fp_unit_fflag_wb_packet.fflags;
    end

    always_comb begin
        if (oldest_fp_issued_fifo_pop)
            fflags = oldest_fp_issued_fifo_data_in.wb2_float ? fp_unit_fflags_table[oldest_fp_issued_fifo_data_in.id] : unit_fflags_table[oldest_fp_issued_fifo_data_in.id];
        else
            fflags = 0;
    end
    //assign fflags_update = oldest_fp_issued_fifo_pop;
endmodule
