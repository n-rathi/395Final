character_initialization :-
   start_task(setup_satisfy_needs, 100).

strategy(setup_satisfy_needs,
	 begin(call(initialize_last_satisfied_times),
	       satisfy_needs)).



%%% Making a loop
strategy(satisfy_needs,
	 begin(
	       satisfy_a_need,
	       satisfy_needs
	      )).



%%% Satisfying a need
strategy(satisfy_a_need, satisfy(hunger,$refrigerator,50)).
strategy(satisfy(hunger,$refrigerator,50),
	 begin(
	       call(log("getting food")),
	       goto($refrigerator),
	       say_string("mmmmmmmm"),
	       call(increase_satisfaction(hunger,50))
	      )).

strategy(satisfy_a_need, satisfy(sleep,$bed,50)).
strategy(satisfy(sleep,$bed,50),
	 begin(
	       call(log("taking a nap")),
	       goto($bed),
	       say_string("zzzzzzzz"),
	       call(increase_satisfaction(sleep,50))
	      )).

strategy(satisfy_a_need, satisfy(bladder,$toilet,40)).
strategy(satisfy(bladder,$toilet,40),
	 begin(
	       call(log("relieving myself")),
	       goto($toilet),
	       say_string("ahhhh"),
	       call(increase_satisfaction(bladder,40))
	      )).

strategy(satisfy_a_need, satisfy(thirst,$'kitchen table',40)).
strategy(satisfy(thirst,$'kitchen table',40),
	 begin(
	       call(log("getting a drink")),
	       goto($'kitchen table'),
	       say_string("sllurrrrpp"),
	       call(increase_satisfaction(thirst,40))
	      )).

strategy(satisfy_a_need, satisfy(fun,$radio,40)).
strategy(satisfy(fun,$radio,40),
	 begin(
	       call(log("need some fun")),
	       goto($radio),
	       say_string("why do we still have a radio in 2015"),
	       call(increase_satisfaction(fun,40))
	      )).

strategy(satisfy_a_need, satisfy(hygiene,$'bathroom sink',40)).
strategy(satisfy(hygiene,$'bathroom sink',40),
	 begin(
	       call(log("getting clean")),
	       goto($'bathroom sink'),
	       say_string("wish i had a shower"),
	       call(increase_satisfaction(hygiene,40))
	      )).


%%% Meta-level reasoning
%%% Desirability_of_satisfying_need is already written elsewhere apparently,
%%%  so I just added distance weighting
strategy(resolve_conflict(satisfy_a_need, StrategyList), satisfy(Need,Object,Delta)) :-
   arg_max(satisfy(Need,Object,Delta),
	  Score,
	   (member(satisfy(Need,Object,Delta), StrategyList),
	    Distance is distance($me, Object),
	    desirability_of_satisfying_need(Need,Delta,Desirability),
	    Score is Desirability/(Distance/4),
	    log($me," desires ", Need, ": ", Score))).



