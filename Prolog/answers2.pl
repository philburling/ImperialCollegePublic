:- set_prolog_flag( toplevel_print_options, [max_depth(100)] ).

%%%
%1%
%%%

%Defining a predicate ' swap_words' for swapping any instances of a specified word in a list with another specified word.

swap_words([],_,_,[]).

swap_words([ListHead|ListTail],Word,Replacement,[Replacement|ModList]):-
	ListHead=Word,swap_words(ListTail,Word,Replacement,ModList).

swap_words([ListHead|ListTail],Word,Replacement,[ListHead|ModList]):-
    \+ListHead=Word,swap_words(ListTail,Word,Replacement,ModList).


%Defining the 'decode' predicate for a particular swap.

decode([],[]).

decode(Message, Decoded_Message):-
      swap_words(Message,bear,double,Replaced_bear),
      swap_words(Replaced_bear,cub,agent,Decoded_Message).
	  

%%%
%2%
%%%

%Defining a predicate 'member' to determine if a constant is a member of another list.
member(Item,[Item|_Tail]).
member(Item,[_Head|Tail]):- member(Item,Tail).

%Defining a predicate to append a list to another list.

append([],List,List).
append([H|L1],L2,[H|L3]):- append(L1,L2,L3).

%Defining a predicate 'member_list' to determine if a list is a member of another list.

member_list(Sublist,List):-append(_HeadList,TailList,List),append(Sublist,_TailofTailList,TailList).

%Defining the agents predicate (as required by the coursework specification)

agents(Message,Decoded_Message,[]):- decode(Message, Decoded_Message), \+setof(Name,(member_list([Name, is, a, double, agent],Decoded_Message),\+((Name=cub;Name=bear;Name=double;Name=agent))),_ListofAgents).

agents(Message,Decoded_Message,ListofAgents):-
	decode(Message, Decoded_Message)
	,setof(
		Name
		,(
			member_list([Name, is, a, double, agent],Decoded_Message)
			,\+((Name=cub;Name=bear;Name=double;Name=agent)))
		,ListofAgents).

/*N.B. While not strictly necessary to include \+Name=bear or \+Name=cub, as the message is decoded,
 I have included them anyway to make it explicit.*/

%%%
%3%
%%%

count_word(W,L,C):-findall(W,member(W,L),L2),length(L2,C).

%%%
%4%
%%%

%Defining a predicate 'count_ag_names' to return a list of people accused of being agents in Message
%along with a count of how many times that name is mentioned in Message.

count_ag_names(Message,[]):-
	\+setof(
			(Name,Count)
			,(
				agents(Message,_Decoded_Message,ListofAgents)
				,member(Name,ListofAgents)
				,count_word(Name,Message,Count))
			,_Ag_name_counts).

count_ag_names(Message,Ag_name_counts):-
	setof(
		(Name,Count)
		,(
			agents(Message,_Decoded_Message,ListofAgents)
			,member(Name,ListofAgents)
			,count_word(Name,Message,Count))
		,Ag_name_counts).

%%%
%5%
%%%

%Defining a predicate 'count_sublist' to count the number of occurrences of a sublist in a list.

count_sublist(S,L,C):-findall(S,member_list(S,L),L2),length(L2,C).

%Defining a predicate 'rev' to reverse a list.

rev(List,ReversedList):- rev(List,[],ReversedList).
rev([Head|Tail],NewList,ReversedList):- rev(Tail,[Head|NewList],ReversedList).
rev([],ReversedList,ReversedList).

%Defining a predicate 'rev_pairs' to reverse a list of atomic pairs, while also reversing the pairs.

rev_pairs([(A,B)|Tail],[(B,A)|ReversedTail]):-rev_pairs(Tail,ReversedTail).
rev_pairs([],[]).


%Defining a predicate 'accusation_counts' to return a list of the names of, and number of times 
%individuals have been named in Message in the form (Name,Count), ordered by Count in descending order.

accusation_counts(M, AC):-
	agents(M,Decoded_Message,ListofAgents)
	,setof(
		(Count,Name)
		,(
			member(Name,ListofAgents)
			,count_sublist([Name, is, a, double, agent],Decoded_Message,Count))
		,List)
	,rev(List,ReversedList)
	,rev_pairs(ReversedList,AC).

accusation_counts(M, []):- agents(Message,Decoded_Message,[]).