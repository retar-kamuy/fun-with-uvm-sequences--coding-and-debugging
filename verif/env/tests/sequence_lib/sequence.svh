`ifndef SEQUENCE_SVH_
`define SEQUENCE_SVH_

class my_sequence extends uvm_sequence#(transaction);
    `uvm_object_utils(my_sequence)

    transaction t;
    int LIMIT;

    function new(string name = "my_sequence");
        super.new(name);
    endfunction

    function void do_record(uvm_recorder recorder);
        super.do_record(recorder);
        `uvm_record_field("name", get_name())
        `uvm_record_field("LIMIT", LIMIT)
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting", UVM_MEDIUM)
        for (int i = 0; i < LIMIT; i++) begin
            t = new($sformatf("t%0d", i));
            start_item(t);
            t.data = i+1 ;

            if (!t.randomize())
                `uvm_fatal(get_type_name(), "Randomize FAILED")
            finish_item(t);
        end
        `uvm_info(get_type_name(), "Finished", UVM_MEDIUM)
    endtask
endclass

class video extends my_sequence;
    `uvm_object_utils(video)

    function new(string name = "video");
        super.new(name);
    endfunction

    int xpixels = 1920;
    int ypixels = 1024;
    int screendots;
    int rate;
    int screens;
    bit [31:0] addr;

    int x;
    int y;

    video_transaction t;

    task body();
        `uvm_info(get_type_name(), "Starting", UVM_MEDIUM)
        screendots = xpixels * ypixels;
        rate = 1_000_000_000 / (60 * screendots);
        $display("rate = %0d", rate);
        forever begin
            addr = 0;
            screens++;
            for (x = 0; x < xpixels; x++) begin
                for (y = 0; y < ypixels; y++) begin
                    t = new($sformatf("t%0d_%0d", x, y));
                    start_item(t);
                    if (!t.randomize())
                        `uvm_fatal(get_type_name(), "Randomize FAILED")
                    t.rw = WRITE;
                    t.addr = addr++;
                    t.duration = rate;
                    finish_item(t);
                end
            end
        end
        `uvm_info(get_type_name(), "Finished", UVM_MEDIUM)
    endtask
endclass

typedef enum bit { STOP, GO } synchro_t;

class synchronizer;
    synchro_t state;
endclass

class synchro extends my_sequence;
    `uvm_object_utils(synchro)

    function new(string name = "synchro");
        super.new(name);
    endfunction

    bit [31:0] start_addr;
    bit [31:0] addr;
    synchronizer s;

    synchro_transaction t;

    task body();
        `uvm_info(get_type_name(), "Starting", UVM_MEDIUM)
        forever begin
            addr = start_addr;
            while (s.state == STOP) begin
                #10;
                `uvm_info(get_type_name(), "Waiting...", UVM_MEDIUM)
            end
            t = new($sformatf("t%0d", addr));
            start_item(t);
            if (!t.randomize())
                `uvm_fatal(get_type_name(), "Randomize FAILED")
            t.rw = WRITE;
            t.addr = addr++;
            finish_item(t);
        end
        `uvm_info(get_type_name(), "Finished", UVM_MEDIUM)
    endtask
endclass

class interrupt_sequence extends my_sequence;
    `uvm_object_utils(interrupt_sequence)

    function new(string name = "interrupt_sequence");
        super.new(name);
    endfunction

    interrupt_transaction t;

    task body();
        forever begin
            `uvm_info(get_type_name(), "Starting", UVM_MEDIUM)
            t = new("isr_transaction");
            start_item(t);
            finish_item(t);
            wait(t.DONE == 1);
            `uvm_info(get_type_name(), $sformatf("Serviced %0d", t.VALUE), UVM_MEDIUM)
        end
    endtask
endclass

class open_door extends my_sequence;
    `uvm_object_utils(open_door)

    function new(string name = "open_door");
        super.new(name);
    endfunction

    read_transaction r;
    write_transaction w;

    task read(input bit[31:0]addr, output bit[31:0]data);
        r = new("r");
        start_item(r);
        if (!r.randomize())
            `uvm_fatal(get_type_name(), "Randomize FAILED")
        r.rw = READ;
        r.addr = addr;
        finish_item(r);
        data = r.data;
    endtask

    task write(input bit[31:0]addr, input bit[31:0]data);
        w = new("w");
        start_item(w);
        if (!w.randomize())
            `uvm_fatal(get_type_name(), "Randomize FAILED")
        w.rw = WRITE;
        w.addr = addr;
        w.data = data;
        finish_item(w);
    endtask

    task body();
        `uvm_info(get_type_name(), "Starting", UVM_MEDIUM)
        wait(0);
        `uvm_info(get_type_name(), "Finished", UVM_MEDIUM)
    endtask
endclass

class write_read_sequence extends my_sequence;
    `uvm_object_utils(write_read_sequence)

    function new(string name = "write_read_sequence");
        super.new(name);
    endfunction

    read_transaction r;
    write_transaction w;

    task body();
        `uvm_info(get_type_name(), "Starting", UVM_MEDIUM)
        for (int i = 0; i < LIMIT; i++) begin
            w = new($sformatf("t%0d", i));
            start_item(w);
            if (!w.randomize())
                `uvm_fatal(get_type_name(), "Randomize FAILED")
            w.rw = WRITE;
            finish_item(w);
        end

        for (int i = 0; i < LIMIT; i++) begin
            r = new($sformatf("t%0d", i));
            start_item(r);
            if (!r.randomize())
                `uvm_fatal(get_type_name(), "Randomize FAILED")
            r.rw = READ;
            r.data = 0;
            finish_item(r);
            if (w.addr != r.data) begin
                `uvm_info(get_type_name(), $sformatf("Mismatch. Wrote %0d, Read %0d",
                    w.addr, r.data), UVM_MEDIUM)
            end
        end
        `uvm_info(get_type_name(), "Finished", UVM_MEDIUM)
    endtask
endclass

class use_c_code_sequence extends my_sequence;
    `uvm_object_utils(use_c_code_sequence)

    function new(string name = "use_c_code_sequence");
        super.new(name);
    endfunction

    int z;

    c_code_transaction t;

    task body();
        forever begin
            `uvm_info(get_type_name(), "Starting", UVM_MEDIUM)
            for (int i = 0; i < 10; i++) begin
                for (int j = 0; j < 10; j++) begin
                    c_code_add(z, i, j);
                    t = new($sformatf("t%0d", i));
                    start_item(t);
                    if (!t.randomize())
                        `uvm_fatal(get_type_name(), "Randomize FAILED")
                    t.duration = z;
                    t.rw = WRITE;
                    finish_item(t);
                end
            end
            `uvm_info(get_type_name(), "Finished", UVM_MEDIUM)
        end
    endtask
endclass

typedef class pong;

class ping extends my_sequence;
    `uvm_object_utils(ping)

    pong pong_h;

    ping_transaction t;
    int LIMIT;

    int waiting;
    int done;

    function new(string name = "ping");
        super.new(name);
        waiting = 1;
        done = 0;
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting", UVM_MEDIUM)
        waiting = 0;
        for (int i = 0; i < LIMIT; i++) begin
            if ((i % 5) == 0) begin
            if (!pong_h.done) waiting = 1;
            pong_h.waiting = 0;
            end
            wait(waiting == 0);
            t = new($sformatf("t%0d", i));
            start_item(t);
            t.data = i+1 ;
            if (!t.randomize())
                `uvm_fatal(get_type_name(), "Randomize FAILED")
            `uvm_info(get_type_name(), $sformatf("Executing %s", t.convert2string()), UVM_MEDIUM)
            finish_item(t);
        end
        pong_h.waiting = 0;
        done = 1;
        `uvm_info(get_type_name(), "Finished", UVM_MEDIUM)
    endtask
endclass

class pong extends my_sequence;
    `uvm_object_utils(pong)

    ping ping_h;

    pong_transaction t;
    int LIMIT;

    int waiting;
    int done;

    function new(string name = "pong");
        super.new(name);
        waiting = 1;
        done = 0;
    endfunction

    task body();
        `uvm_info(get_type_name(), "Starting", UVM_MEDIUM)
        for (int i = 0; i < LIMIT; i++) begin
            if ((i % 5) == 0) begin
                if (!ping_h.done)
                    waiting = 1;
                ping_h.waiting = 0;
            end
            wait(waiting == 0);
            t = new($sformatf("t%0d", i));
            start_item(t);
            t.data = i+1 ;
            if (!t.randomize())
                `uvm_fatal(get_type_name(), "Randomize FAILED")
            `uvm_info(get_type_name(), $sformatf("Executing %s", t.convert2string()), UVM_MEDIUM)
            finish_item(t);
        end
        ping_h.waiting = 0;
        `uvm_info(get_type_name(), "Finished", UVM_MEDIUM)
    endtask
endclass

`endif  // SEQUENCE_SVH_