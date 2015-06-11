%%
%% Responding to imperatives
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% RECEIVING DRINK ORDER COMMAND
strategy(respond_to_dialog_act(command(Requestor, $me, Task)),
	 follow_command(Requestor, Task, RequestStatus)) :-
   request_status(Requestor, Task, RequestStatus).

request_status(_Requestor, order_drink(Drink), drink_order) :-
	member(Drink, [margarita, julep]),
	!.

request_status(_Requestor, cost_drink(Drink, Cost), drink_cost) :-
	member(Drink, [margarita, julep]),
	!.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

request_status(_Requestor, Task, immoral) :-
   @immoral(Task),
   !.
request_status(_Requestor, Task, non_normative) :-
   \+ well_typed(Task, action, _),
   !.
request_status(_Requestor, Task, unachievable(Reason)) :-
   \+ have_strategy(Task),
   once(diagnose(Task, Reason)),
   !.
request_status(Requestor, Task, incriminating(P)) :-
   guard_condition(Task, P),
   pretend_truth_value(Requestor, P, Value),
   Value \= true,
   !.
request_status(_Requestor, _Task, normal).

strategy(follow_command(Requestor, Task, normal),
	 if(dialog_task(Task),
	    Task,
	    call(add_pending_task(on_behalf_of(Requestor, Task))))).

:- public dialog_task/1.
dialog_task(tell_about(_,_,_)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FOLLOWING DRINK ORDER COMMAND

trace_task($kavi, _).

strategy(follow_command(_, _, drink_order),
	 make_drink(margarita)).

default_strategy(follow_command(_, _, drink_cost),
	 say_string("Seven dollars.")).

strategy(make_drink(_),
	begin(
	say_string("Ok."),
	say_string("Coming right up."),
	goto($refrigerator),
	say_string("getting the ingredients..."),
	goto($pc),
	say_string("enjoy!")
	)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


strategy(follow_command(_, _, immoral),
	 say_string("That would be immoral.")).
strategy(follow_command(_, _, non_normative),
	 say_string("That would be weird.")).
strategy(follow_command(_, _, unachievable(Reason)),
	 explain_failure(Reason)).
strategy(follow_command(_, _, incriminating(_)),
	 say_string("Sorry, I can't.")).

diagnose(Task, ~Precondition) :-
   unsatisfied_task_precondition(Task, Precondition).

default_strategy(explain_failure(_),
		 say_string("I don't know how.")).
strategy(explain_failure(~know(X:location(Object, X))),
	 speech(["I don't know where", np(Object), "is"])).

strategy(tell_about($me, _, Topic),
	 describe(Topic, general, null)).

normalize_task(go($me, Location),
	       goto(Location)).
normalize_task(take($me, Patient, _),
	       pickup(Patient)).
normalize_task(put($me, Patient, Destination),
	      move($me, Patient, Destination)) :-
   nonvar(Destination).

strategy(talk($me, $addressee, Topic),
	 describe(Topic, introduction, null)) :-
   nonvar(Topic).

strategy(talk($me, ConversationalPartner, Topic),
	 add_conversation_topic(ConversationalPartner, Topic)) :-
   ConversationalPartner \= $addressee.

strategy(add_conversation_topic(Person, Topic),
	 assert(/pending_conversation_topics/Person/ask_about($me,
							      Person,
							      Topic))) :-
   var(Topic) -> Topic = Person ; true.

strategy(end_game(_,_), end_game(null)).
