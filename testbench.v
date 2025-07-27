`timescale 1ns / 1ps

module tb_parking_system;

  // Inputs
  reg clk;
  reg reset_n;
  reg sensor_entrance;
  reg sensor_exit;
  reg [3:0] password;

  // Outputs
  wire GREEN_LED;
  wire RED_LED;
  wire [2:0] indicator;
  wire [3:0] countcar;

  // Instantiate the Unit Under Test (UUT)
  parking_system uut (
    .clk(clk),
    .reset_n(reset_n),
    .sensor_entrance(sensor_entrance),
    .sensor_exit(sensor_exit),
    .password(password),
    .GREEN_LED(GREEN_LED),
    .RED_LED(RED_LED),
    .countcar(countcar),
    .indicator(indicator)
  );

  // Clock generation (50 MHz)
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  // Test sequence
  initial begin
    // Initialize Inputs
    $display("\nInitializing Testbench...");
    reset_n = 1'b0;
    sensor_entrance = 1'b0;
    sensor_exit = 1'b0;
    password = 4'b0000;
    
    // System Reset
    $display("\n[TEST] System Reset");
    #100;
    reset_n = 1'b1;
    #50;
    if (countcar !== 4'b0000) $error("Reset failed: Counter not zero");
    else $display("Reset successful: Counter = %0d", countcar);
    
    // ========== ENTRY TESTS ========== //
    
    // Test Case 1: Correct password entry
    $display("\n[TEST 1] Valid entry with correct password");
    password = 4'b1001; // Correct password
    sensor_entrance = 1'b1;
    #50; // Wait for state transition
    if (indicator !== 3'b010) $error("Failed to enter PASSWORD_CHECK state");
    #50; // Complete password check
    sensor_entrance = 1'b0;
    #100;
    if (GREEN_LED !== 1'b1) $error("Green LED not activated");
    if (countcar !== 4'b0001) $error("Counter not incremented");
    else $display("Entry successful: Count = %0d", countcar);
    #350;
    
    // Test Case 2: Incorrect password entry
    $display("\n[TEST 2] Invalid entry with wrong password");
    password = 4'b1010; // Wrong password
    sensor_entrance = 1'b1;
    #50;
    if (indicator !== 3'b010) $error("Failed to enter PASSWORD_CHECK state");
    #50;
    sensor_entrance = 1'b0;
    #100;
    if (RED_LED !== 1'b1) $error("Red LED not activated");
    if (countcar !== 4'b0001) $error("Counter changed on failed entry");
    else $display("Entry denied successfully: Count = %0d", countcar);
    #350;
    
    // Test Case 3: Rapid consecutive entries
    $display("\n[TEST 3] Multiple valid entries");
    repeat(3) begin
      password = 4'b1001;
      sensor_entrance = 1'b1;
      #100;
      sensor_entrance = 1'b0;
      #200;
    end
    if (countcar !== 4'b0100) $error("Counter mismatch after multiple entries");
    else $display("Multiple entries successful: Count = %0d", countcar);
    #300;
    
    // ========== EXIT TESTS ========== //
    
    // Test Case 4: Normal exit
    $display("\n[TEST 4] Valid exit");
    sensor_exit = 1'b1;
    #100;
    sensor_exit = 1'b0;
    #100;
    if (countcar !== 4'b0011) $error("Counter not decremented");
    else $display("Exit successful: Count = %0d", countcar);
    #300;
    
    // Test Case 5: Multiple exits
    $display("\n[TEST 5] Multiple exits");
    repeat(2) begin
      sensor_exit = 1'b1;
      #100;
      sensor_exit = 1'b0;
      #200;
    end
    if (countcar !== 4'b0001) $error("Counter mismatch after multiple exits");
    else $display("Multiple exits successful: Count = %0d", countcar);
    #300;
    
    // ========== EDGE CASES ========== //
    
    // Test Case 6: Parking full scenario
    $display("\n[TEST 6] Parking full condition");
    // Fill remaining spots
    repeat(14) begin
      password = 4'b1001;
      sensor_entrance = 1'b1;
      #100;
      sensor_entrance = 1'b0;
      #200;
    end
    if (countcar !== 4'b1111) $error("Counter not at full capacity");
    else $display("Parking lot filled: Count = %0d", countcar);
    
    // Attempt overflow entry
    password = 4'b1001;
    sensor_entrance = 1'b1;
    #100;
    sensor_entrance = 1'b0;
    #100;
    if (countcar !== 4'b1111) $error("Counter overflowed");
    if (RED_LED !== 1'b1) $error("Full condition not detected");
    else $display("Overflow prevented successfully");
    #300;
    
    // Test Case 7: Empty parking lot
    $display("\n[TEST 7] Empty parking condition");
    // Empty the lot
    repeat(15) begin
      sensor_exit = 1'b1;
      #100;
      sensor_exit = 1'b0;
      #200;
    end
    if (countcar !== 4'b0000) $error("Counter not empty");
    else $display("Parking lot emptied: Count = %0d", countcar);
    
    // Attempt underflow exit
    sensor_exit = 1'b1;
    #100;
    sensor_exit = 1'b0;
    #100;
    if (countcar !== 4'b0000) $error("Counter underflowed");
    else $display("Underflow prevented successfully");
    #300;
    
    // ========== STRESS TEST ========== //
    $display("\n[TEST 8] Stress test: Rapid entries/exits");
    fork
      // Entry thread
      begin
        repeat(10) begin
          password = 4'b1001;
          sensor_entrance = 1'b1;
          #50;
          sensor_entrance = 1'b0;
          #150;
        end
      end
      // Exit thread
      begin
        #100; // Offset start
        repeat(10) begin
          sensor_exit = 1'b1;
          #50;
          sensor_exit = 1'b0;
          #150;
        end
      end
    join
    $display("Final count after stress test: %0d", countcar);
    
    // Finish simulation
    #500;
    $display("\nAll tests completed successfully!");
    $finish;
  end
  
  // Enhanced monitoring with state names
  initial begin
    $timeformat(-9, 2, " ns", 10);
    forever begin
      #10;
      $display("Time=%t | State=%s | Count=%0d | Green=%b Red=%b", 
               $time, get_state_name(indicator), countcar, GREEN_LED, RED_LED);
    end
  end
  
  // Function to convert state codes to names
  function string get_state_name(input [2:0] state);
    case(state)
      3'b000: return "IDLE";
      3'b010: return "PASSWORD_CHECK"; 
      3'b001: return "ENTRY_GRANTED";
      3'b100: return "EXIT_GRANTED";
      3'b110: return "FULL";
      default: return "UNKNOWN";
    endcase
  endfunction

endmodule