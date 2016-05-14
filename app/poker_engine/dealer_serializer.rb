module DealerSerializer
  extend ActiveSupport::Concern

  def serialize
    config = Marshal.dump(@config)
    table = Marshal.dump(@table)
    build_state_dump(table, config).to_json
  end

  class_methods do
    def deserialize(components_holder, json)
     dump = JSON.parse(json)
     round_manager = components_holder[:round_manager]
     state = dump["round_manager"]
     street = state["street"]
     agree_num = state["agree_num"]
     next_player = state["next_player"]
     round_manager.set_state(street, agree_num, next_player)

     broadcaster = components_holder[:broadcaster]
     broadcaster.ask_counter = dump["broadcaster"]["ask_counter"]
     config = Marshal.load(dump["config"])
     table = Marshal.load(dump["table"])

      components_holder
        .merge!( { config: config } )
        .merge!( { table: table } )
        .merge!( { round_manager: round_manager } )
        .merge!( { broadcaster: broadcaster } )
      Dealer.new(components_holder, round_count=dump["round_count"])
    end
  end

  private

   def build_state_dump(table, config)
     {
       "config" => config,
       "table" => table,
       "round_count" => @round_count,
       "round_manager" => {
         "street" => @round_manager.street,
         "agree_num" => @round_manager.agree_num,
         "next_player" => @round_manager.next_player
       },
       "broadcaster" => {
         "ask_counter" => @broadcaster.ask_counter
       }
     }
   end

   def round_manager_from_dump(round_manager, dump)
     state = dump["round_manager"]
     round_manager.tap { |round_manager|
       street = state["street"]
       agree_num = state["agree_num"]
       next_player = state["next_player"]
       round_manager.set_state(street, agree_num, next_player)
       }
   end

end
