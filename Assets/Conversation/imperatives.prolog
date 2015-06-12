%%
%% Responding to imperatives
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% RECEIVING DRINK ORDER COMMAND
strategy(respond_to_dialog_act(command(Requestor, $me, Task)),
	 follow_command(Requestor, Task, RequestStatus)) :-
   request_status(Requestor, Task, RequestStatus).

request_status(_Requestor, order_drink(Drink), drink_order) :-
	drink(Drink,_,_),
	!.

request_status(_Requestor, query_ingredients(Drink), ingredient_query) :-
	drink(Drink,_,_),
	!.

request_status(_Requestor, query_cost(Drink), cost_query) :-
	drink(Drink,_,_),
	!.	

request_status(_Requestor, query_menu, menu_query) :-
	true,
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



%%% %%% Bartender stuff %%% %%% %%% %%% 


%%% Telling how much a drink costs
strategy(follow_command(_, query_cost(Drink), cost_query),
	 tell_cost(Drink)).

strategy(tell_cost(Drink),
	say_string(String)
	) :-
	(drink(Drink, Cost, _),
	word_list(String, [a, Drink, costs, Cost, dollars])).


%%% Listing a drink's ingredients
strategy(follow_command(_, query_ingredients(Drink), ingredient_query),
	 describe_drink(Drink)).

strategy(describe_drink(Drink),
	say_string(String)
	) :- 
	drink(Drink, _, I),
	insert_commas(I, Ingredients),
	append([the, Drink, has, ':'], Ingredients, List),
	word_list(String, List).


strategy(list_ingredients(Drink),
	say_string(String)
	) :- 
	drink(Drink, _, I),
	insert_commas(I, Ingredients),
	word_list(String, Ingredients).


%%% Fulfilling drink order
strategy(follow_command(_, order_drink(Drink), drink_order),
	 make_drink(Drink)).

strategy(make_drink(Drink),
	begin(
		say_string("Coming right up."),
		begin(
			sleep(1),
			goto($refrigerator),
			say_string("hmmm..."),
			sleep(2),
			list_ingredients(Drink),
			sleep(2)
		),
		begin(
			goto($'kitchen sink'),
			say_string("*mix mix mix*"),
			sleep(1),
			say_string("*mix mix mix*"),
			sleep(2)
		),
		goto($'kitchen table'),
		say_string(String)
	)) :-
	word_list(String, [enjoy, your, Drink, '!']).


%%% Listing menu items
strategy(follow_command(_, _, menu_query),
	 list_menu).

strategy(list_menu,
	say_string(String)) :-
	findall(Drink, drink(Drink,_,_), L),
	insert_commas(L, L2),
	append(['I',can,make,':'], L2, L3),
	word_list(String, L3).


insert_commas([],[]).
insert_commas([H|T],[H,', '|TC]):-
   insert_commas(T,TC).
