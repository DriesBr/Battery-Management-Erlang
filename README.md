# Battery-Management-Erlang
School project battery management

This project represent a battery management. The battery needs to be charge and discharge with a consumer.
The battery can only charged if the generator (GEN) is active and when the battery reach his bottom voltage.
When the battery is charged at the right voltage the battery can power the consumer.
Every change will be captured in a logbook (survivor).

Program instructions: 
  1. c(gpio).
  2. c(logbook).
  3. c(batMan).
  4. {O,I} = batMan:start().
  5. batMan:init(O,I).
  6. Programma is running u can use the shell for other tasks.
  7. observer:start().      % this is for checking the logbook
  8. batMan:stop(O,I).      % stop program 
  
logbook instructions:
  BAT LOW         --> battery is to low for the consumer and need to be charged
  BAT HIGH        --> battery is fully charged and can be used for the consumer
  BAT CHARGE      --> battery is charging
  GEN NOT ACTIVE  --> generator is not active and can't charge the battery
  STOP            --> program stopped and every pin is put down for safety
