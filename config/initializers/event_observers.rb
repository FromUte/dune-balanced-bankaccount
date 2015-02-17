event_observer = Dune::Balanced::EventRegistered.new
Dune::Balanced::Event.add_observer(event_observer, :confirm)
