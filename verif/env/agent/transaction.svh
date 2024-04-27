`ifndef TRANSACTION_SVH_
`define TRANSACTION_SVH_

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef enum bit[1:0] { WRITE, READ, IDLE} rw_t;

import "DPI-C" context function void c_code_add(output int z, input int a, int b);
export "DPI-C" function sv_code;

function void sv_code(int z);
    $display("sv_code(z=%0d)", z);
endfunction

class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction)

    rand rw_t rw;
    rand bit [31:0] addr;
         bit [31:0] data;
    rand int duration;

    constraint rw_value {
        rw != IDLE;
    }

    constraint addr_value {
        addr > 1;
        addr < 10;
    };

    constraint value {
        duration > 1;
        duration < 10;
    };

    function void post_randomize();
        data = addr;
    endfunction

    function new(string name = "transaction");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("[%s] %s: addr=%0d, data=%0d, duration=%0d",
            get_type_name(), rw.name(), addr, data, duration);
    endfunction

    function void do_record(uvm_recorder recorder);
        super.do_record(recorder);
        `uvm_record_field("name", get_name())
        `uvm_record_field("rw", rw.name())
        `uvm_record_field("addr", addr)
        `uvm_record_field("data", data)
        `uvm_record_field("duration", duration)
    endfunction
endclass

class interrupt_transaction extends transaction;
    `uvm_object_utils(transaction)

    int VALUE;
    bit DONE;

    function new(string name = "transaction");
        super.new(name);
        DONE = 0;
    endfunction

    function string convert2string();
        return $sformatf("[%s] VALUE=%0d", get_type_name(), VALUE);
    endfunction

    function void do_record(uvm_recorder recorder);
        `uvm_record_field("VALUE", VALUE)
    endfunction
endclass

// Extended classes for self-documentation
class video_transaction extends transaction;
    `uvm_object_utils(video_transaction)
    function new(string name = "video_transaction");
        super.new(name);
    endfunction
endclass

class synchro_transaction extends transaction;
    `uvm_object_utils(synchro_transaction)
    function new(string name = "synchro_transaction");
        super.new(name);
    endfunction
endclass

class write_transaction extends transaction;
    `uvm_object_utils(write_transaction)
    function new(string name = "write_transaction");
        super.new(name);
    endfunction
endclass

class read_transaction extends transaction;
    `uvm_object_utils(read_transaction)
    function new(string name = "read_transaction");
        super.new(name);
    endfunction
endclass

class c_code_transaction extends transaction;
    `uvm_object_utils(c_code_transaction)
    function new(string name = "c_code_transaction");
        super.new(name);
    endfunction
endclass

class ping_transaction extends transaction;
    `uvm_object_utils(ping_transaction)
    function new(string name = "ping_transaction");
        super.new(name);
    endfunction
endclass

class pong_transaction extends transaction;
    `uvm_object_utils(pong_transaction)
    function new(string name = "pong_transaction");
        super.new(name);
    endfunction
endclass

`endif  // TRANSACTION_SVH_
