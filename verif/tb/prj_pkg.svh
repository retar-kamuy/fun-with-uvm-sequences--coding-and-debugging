`ifndef PRJ_PKG_SVH_
`define PRJ_PKG_SVH_

package prj_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "../env/agent/transaction.svh"
    `include "../env/agent/driver.svh"
    `include "../env/tests/sequence_lib/sequence.svh"
    `include "../env/tests/test.svh"
endpackage

`endif  // PRJ_PKG_SVH_