`ifndef TEST_SVH_
`define TEST_SVH_

class test extends uvm_test;
    `uvm_component_utils(test)

    uvm_sequencer#(transaction) sqr;
    driver d;

    my_sequence seq;
    ping ping_h;
    pong pong_h;

    open_door open_door_h;

    synchro synchro_A_h;
    synchro synchro_B_h;
    synchronizer s;

    video video_h;
    interrupt_sequence isr_h;

    write_read_sequence write_read_sequence_h;
    use_c_code_sequence use_c_code_sequence_h;

    function new(string name = "test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        sqr = new("sqr", this);
        d = new("d", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        d.seq_item_port.connect(sqr.seq_item_export);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        fork
            begin
                #100_000;
                phase.drop_objection(this);
            end
        join_none

        fork
            forever begin
                video_h = new("video");
            video_h.start(sqr);
            end
        join_none

        fork
            forever begin
                isr_h = new("isr");
                isr_h.start(sqr);
            end
        join_none

        open_door_h = new("open_door");

        fork
            open_door_h.start(sqr);
            begin
                bit [31:0] rdata;
                for (int i = 0; i < 100; i++) begin
                    open_door_h.write(i, i+1);
                    open_door_h.read(i, rdata);
                    if ( rdata != i+1 ) begin
                        `uvm_info(get_type_name(), $sformatf("Error: Wrote '%0d', Read '%0d'", i+1, rdata), UVM_MEDIUM)
                    end
                end
            end
        join_none

        s = new();
        synchro_A_h = new("synchroA");
        synchro_B_h = new("synchroB");

        synchro_A_h.s = s;
        synchro_A_h.start_addr = 2;
        synchro_B_h.s = s;
        synchro_B_h.start_addr = 2002;

        fork
            forever begin
                #100;
                s.state = GO;
                #20;
                s.state = STOP;
            end
        join_none

        fork
            forever begin
                synchro_A_h.start(sqr);
            end
            forever begin
                synchro_B_h.start(sqr);
            end
        join_none

        fork
            forever begin
                use_c_code_sequence_h = new("use_c_code_sequence_h");
                use_c_code_sequence_h.start(sqr);
            end
        join_none

        fork
            forever begin
                write_read_sequence_h = new("write_read_sequence_h");
                write_read_sequence_h.LIMIT = 25;
                write_read_sequence_h.start(sqr);
            end
        join_none

        ping_h = new("ping_h");
        ping_h.LIMIT = 25;
        pong_h = new("pong_h");
        pong_h.LIMIT = 40;

        ping_h.pong_h = pong_h;
        pong_h.ping_h = ping_h;

        fork
            forever begin
                fork
                    ping_h.start(sqr);
                    pong_h.start(sqr);
                join
            end
        join_none

        fork
            begin
                for (int i = 0; i < 4; i++) begin
                    fork
                        automatic int j = i;
                        seq = new($sformatf("seq%0d", j));
                        seq.LIMIT = 25 * (j+1);
                        seq.start(sqr);
                    join_none
                end
                wait fork;
            end
        join_none

        #2468619; // Safety Valve. Never reached.
        phase.drop_objection(this);
    endtask
endclass

`endif  // TEST_SVH_
