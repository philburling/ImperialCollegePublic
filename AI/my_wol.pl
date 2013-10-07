
:- include('war_of_life.pl').

%%%%%%%%%%%%%%%%%%%%% PART 1  - TEST_STRATEGY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%% HELPER FUNCTIONS %%%%%%%%%

% This predicate returns both player's win/loss status into a numerical value.
% It also returns stalemate, draw and exhaust outcomes as a numerical value.
roundResults(WinningPlayer,FirstPlayerRoundResult,SecondPlayerRoundResult,DrawRoundResult):-
	testPlayerWin('b',WinningPlayer,FirstPlayerRoundResult), % The starting player is defined as blue.
	testPlayerWin('r',WinningPlayer,SecondPlayerRoundResult),
	testDraw(FirstPlayerRoundResult,SecondPlayerRoundResult,DrawRoundResult).
	% -Assuming stalemate, draw and exhaust results all count as draws. Otherwise would use 'testPlayerWin('draw',WinningPlayer,Draws).'

testPlayerWin(WinningPlayer,WinningPlayer,1).
testPlayerWin(PlayerColour,WinningPlayer,0):-
	PlayerColour \= WinningPlayer.

testDraw(FirstPlayerRoundResult,SecondPlayerRoundResult,1):-
	FirstPlayerRoundResult =:= SecondPlayerRoundResult.
	% Could have used '=' here but thought this predicate could be more useful later if it compared whole expressions.

testDraw(FirstPlayerRoundResult,SecondPlayerRoundResult,0):-
	FirstPlayerRoundResult =\= SecondPlayerRoundResult.
	% Could have used '=' here but thought this predicate could be more useful later if it compared whole expressions.

% Predicates to compare and find the longest, and shortest of two values.

findLongestValue(Prev_LongestValue,Value,Prev_LongestValue):- Prev_LongestValue >= Value.
findLongestValue(Prev_LongestValue,Value,Value):- Prev_LongestValue < Value.

findShortestValue(Prev_ShortestValue,Value,Prev_ShortestValue):- Prev_ShortestValue =< Value.
findShortestValue(Prev_ShortestValue,Value,Value):- Prev_ShortestValue > Value.

% Predicate to get the new average when taking an old average and adding a new value to the set.

getMeanAverage(Prev_MeanAverage, Prev_Denominator, NewValue, New_MeanAverage):-
	Current_Denominator is Prev_Denominator + 1,
	New_MeanAverage is ((NewValue + (Prev_MeanAverage*Prev_Denominator))/Current_Denominator).

/* If a number of moves is exhaustive, return the number of moves for that round, 
else return 0 (guaranteed not to be the longest number).*/
	checkExhaustive('exhaust',_,0).
	checkExhaustive(WinningPlayer,NumMoves,NumMoves):- WinningPlayer \= 'exhaust'.

% test_strategy/11 - Base-case
	
test_strategy(
	FirstPlayerStrategy,
	SecondPlayerStrategy,
	1,
	DrawRoundResult,
	FirstPlayerRoundResult,
	SecondPlayerRoundResult,
	NumMovesIfNonExhaustive,
	NumMoves,
	NumMoves,
	RoundTime
	):-
		% Get the walltime so that the timer from the last call for walltime is set/reset
		statistics(walltime,[_,_]), 
		
		% Play this round.
		play(quiet,FirstPlayerStrategy,SecondPlayerStrategy,NumMoves,WinningPlayer),
		
		% Get the time elapsed since the last call for walltime -i.e. the time for this game.
		statistics(walltime,[_,RoundTime]),
		
		% Obtain values for win/loss count update...
		roundResults(WinningPlayer,FirstPlayerRoundResult,SecondPlayerRoundResult,DrawRoundResult),
		
		% If the game was exhaustive, return 0 for NumMovesIfNonExhaustive, otherwise make it NumMoves.
		checkExhaustive(WinningPlayer,NumMoves,NumMovesIfNonExhaustive).

% test_strategy/11 - Recursive-case
		
test_strategy(
	FirstPlayerStrategy,
	SecondPlayerStrategy,
	GamesSoFar,
	Draws,
	FirstPlayerWins,
	SecondPlayerWins,
	LongestNumberOfMoves,
	ShortestNumberOfMoves,
	AverageNumberOfMoves,
	AverageTimeForGame
	):-
		GamesSoFar > 1, % i.e. If there are no games left to play, go to the base case instead.
		
		% Recurse until reach the base case...
		Prev_GamesSoFar is GamesSoFar - 1,
		test_strategy(
			FirstPlayerStrategy,
			SecondPlayerStrategy,
			Prev_GamesSoFar,
			Prev_Draws,
			Prev_FirstPlayerWins,
			Prev_SecondPlayerWins,
			Prev_LongestNumberOfMoves,
			Prev_ShortestNumberOfMoves,
			Prev_AverageNumberOfMoves,
			Prev_AverageTimeForGame
		),
		
		% See the base-case for an explanation of the lines of code in this block.
		statistics(walltime,[_,_]), 
		play(quiet,FirstPlayerStrategy,SecondPlayerStrategy,NumMoves,WinningPlayer),
		statistics(walltime,[_,RoundTime]),
		roundResults(WinningPlayer,FirstPlayerRoundResult,SecondPlayerRoundResult,DrawRoundResult),
		checkExhaustive(WinningPlayer,NumMoves,NumMovesIfNonExhaustive),
		
		% Update values for this round.
		FirstPlayerWins is Prev_FirstPlayerWins + FirstPlayerRoundResult,
		SecondPlayerWins is Prev_SecondPlayerWins + SecondPlayerRoundResult,
		Draws is Prev_Draws + DrawRoundResult,
		findLongestValue(Prev_LongestNumberOfMoves,NumMovesIfNonExhaustive,LongestNumberOfMoves),
		findShortestValue(Prev_ShortestNumberOfMoves,NumMoves,ShortestNumberOfMoves),
		getMeanAverage(Prev_AverageNumberOfMoves, Prev_GamesSoFar, NumMoves, AverageNumberOfMoves),
		getMeanAverage(Prev_AverageTimeForGame, Prev_GamesSoFar, RoundTime, AverageTimeForGame).
				
%%%%%%%%%%%%% TOP LEVEL FUNCTION %%%%%%%%%%%%%

% test_strategy/3 - This version takes minimal user input and prints game statistics to screen...

test_strategy(NumberOfGames,FirstPlayerStrategy,SecondPlayerStrategy):-
	test_strategy(
		FirstPlayerStrategy,
		SecondPlayerStrategy,
		NumberOfGames,
		Draws,
		FirstPlayerWins,
		SecondPlayerWins,
		LongestNumberOfMoves,
		ShortestNumberOfMoves,
		AverageNumberOfMoves,
		AverageTimeForGame
	),
	% Print statistics to the screen...
	write('Number of draws: '), write(Draws), nl,
	write('Total player 1 (blue) wins: '), write(FirstPlayerWins), nl,
	write('Total player 2 (red) wins: '), write(SecondPlayerWins), nl,
	write('Longest (non-exhaustive) game: '), write(LongestNumberOfMoves), nl,
	write('Shortest game: '), write(ShortestNumberOfMoves), nl,
	write('Average game length (including exhaustives): '),	write(AverageNumberOfMoves), nl,
	write('Average game time: '), write(AverageTimeForGame), nl.
	
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PART 2 - IMPLEMENTING STRATEGIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%% HELPER FUNCTIONS %%%%%%%%%%%%%%%%%

/* getPossibleMoves/3 - Return a list of possible moves for a given player colour, 
given a particular board state. */

getPossibleMoves('b',[AliveBlues,AliveReds],PossMoves):-
	findall(
		[A,B,MA,MB],
		(
			member([A,B], AliveBlues),
			neighbour_position(A,B,[MA,MB]),
			\+member([MA,MB],AliveBlues),
			\+member([MA,MB],AliveReds)
		),
		PossMoves).

getPossibleMoves('r',[AliveBlues,AliveReds],PossMoves):-
	findall(
		[A,B,MA,MB],
		(
			member([A,B], AliveReds),
			neighbour_position(A,B,[MA,MB]),
			\+member([MA,MB],AliveReds),
			\+member([MA,MB],AliveBlues)
		),
		PossMoves).

/* getPieceCountsAfterMove/4 - Retrieve a list of moves, each grouped with the counts 
of player pieces after Conways Crank has been turned after that move. */

getPieceCountsAfterMove('b',PossMoves,[AliveBlues,AliveReds],PieceCountList):-
	findall([Move,BlueCount,RedCount],
		(
			member(Move,PossMoves),
			alter_board(Move,AliveBlues,NewAliveBlues),
			next_generation([NewAliveBlues,AliveReds],[PostCrankBlues,PostCrankReds]),
			length(PostCrankBlues,BlueCount),
			length(PostCrankReds,RedCount)
		),
		PieceCountList).

getPieceCountsAfterMove('r',PossMoves,[AliveBlues,AliveReds],PieceCountList):-
	findall([Move,BlueCount,RedCount],
		(
			member(Move,PossMoves),
			alter_board(Move,AliveReds,NewAliveReds),
			next_generation([AliveBlues,NewAliveReds],[PostCrankBlues,PostCrankReds]),
			length(PostCrankBlues,BlueCount),
			length(PostCrankReds,RedCount)
		),
		PieceCountList).

/* getSmallestOpponentCount/3
 - Get the player move (and counts of each players pieces) with the smallest 
 number of opponent pieces remaining after Conway's Crank
 has been turned for that move. */

getSmallestOpponentCount(PlayerColour,PieceCountList,Smallest):-
	PieceCountList = [HeadItem|_],
	getSmallestOpponentCount(PlayerColour,PieceCountList,HeadItem,Smallest).

getSmallestOpponentCount('b',[HeadItem|TailItems],SmallestSoFar,Smallest):- 
	HeadItem = [_|Counts],
	Counts = [_|RedCount],
	SmallestSoFar = [_|SmallestCounts],
	SmallestCounts = [_|SmallestRedCount],
	RedCount < SmallestRedCount,
	getSmallestOpponentCount('b',TailItems,HeadItem,Smallest).

getSmallestOpponentCount('b',[HeadItem|TailItems],SmallestSoFar,Smallest):- 
	HeadItem = [_|Counts],
	Counts = [_|RedCount],
	SmallestSoFar = [_|SmallestCounts],
	SmallestCounts = [_|SmallestRedCount],
	RedCount >= SmallestRedCount,
	getSmallestOpponentCount('b',TailItems,SmallestSoFar,Smallest).	

getSmallestOpponentCount('r',[HeadItem|TailItems],SmallestSoFar,Smallest):- 
	HeadItem = [_|Counts],
	Counts = [BlueCount|_],
	SmallestSoFar = [_|SmallestCounts],
	SmallestCounts = [SmallestBlueCount|_],
	BlueCount < SmallestBlueCount,
	getSmallestOpponentCount('r',TailItems,HeadItem,Smallest).

getSmallestOpponentCount('r',[HeadItem|TailItems],SmallestSoFar,Smallest):- 
	HeadItem = [_|Counts],
	Counts = [BlueCount|_],
	SmallestSoFar = [_|SmallestCounts],
	SmallestCounts = [SmallestBlueCount|_],
	BlueCount >= SmallestBlueCount,
	getSmallestOpponentCount('r',TailItems,SmallestSoFar,Smallest).	
	
getSmallestOpponentCount(_,[],Smallest,Smallest).		

/* getLargestOwnCount/3
 - Get the player move (and counts of each players pieces) with the
 largest number of that players pieces remaining after Conway's Crank
 has been turned for that move. */

getLargestOwnCount(PlayerColour,PieceCountList,Largest):-
	PieceCountList = [HeadItem|_],
	getLargestOwnCount(PlayerColour,PieceCountList,HeadItem,Largest).

getLargestOwnCount('b',[HeadItem|TailItems],LargestSoFar,Largest):- 
	HeadItem = [_|Counts],
	Counts = [BlueCount|_],
	LargestSoFar = [_|LargestCounts],
	LargestCounts = [LargestBlueCount|_],
	BlueCount > LargestBlueCount,
	getLargestOwnCount('b',TailItems,HeadItem,Largest).

getLargestOwnCount('b',[HeadItem|TailItems],LargestSoFar,Largest):- 
	HeadItem = [_|Counts],
	Counts = [BlueCount|_],
	LargestSoFar = [_|LargestCounts],
	LargestCounts = [LargestBlueCount|_],
	BlueCount =< LargestBlueCount,
	getLargestOwnCount('b',TailItems,LargestSoFar,Largest).	

getLargestOwnCount('r',[HeadItem|TailItems],LargestSoFar,Largest):- 
	HeadItem = [_|Counts],
	Counts = [_|RedCount],
	LargestSoFar = [_|LargestCounts],
	LargestCounts = [_|LargestRedCount],
	RedCount > LargestRedCount,
	getLargestOwnCount('r',TailItems,HeadItem,Largest).

getLargestOwnCount('r',[HeadItem|TailItems],LargestSoFar,Largest):- 
	HeadItem = [_|Counts],
	Counts = [_|RedCount],
	LargestSoFar = [_|LargestCounts],
	LargestCounts = [_|LargestRedCount],
	RedCount =< LargestRedCount,
	getLargestOwnCount('r',TailItems,LargestSoFar,Largest).	
	
getLargestOwnCount(_,[],Largest,Largest).	

/* getBestLandGrabCount(PlayerColour,PieceCountList,Smallest)
 - Get the player move (and counts of each players pieces) with the 
greatest positive difference between that players remaining 
 peices and the opponents remaining peices after Conway's Crank has been turned after that move. */

getBestLandGrabCount(PlayerColour,PieceCountList,LandGrab):-
	PieceCountList = [HeadItem|_],
	getBestLandGrabCount(PlayerColour,PieceCountList,HeadItem,LandGrab).

getBestLandGrabCount('b',[HeadItem|TailItems],LandGrabSoFar,LandGrab):- 
	HeadItem = [_|Counts],
	Counts = [BlueCount|RedCount],
	NewLandGrabCount is BlueCount - RedCount,
	LandGrabSoFar = [_|LandGrabCounts],
	LandGrabCounts = [LandGrabBlueCount|LandGrabRedCount],
	LandGrabOldCount is LandGrabBlueCount - LandGrabRedCount,
	NewLandGrabCount > LandGrabOldCount,
	getBestLandGrabCount('b',TailItems,HeadItem,LandGrab).

getBestLandGrabCount('b',[HeadItem|TailItems],LandGrabSoFar,LandGrab):- 
	HeadItem = [_|Counts],
	Counts = [BlueCount|RedCount],
	NewLandGrabCount is BlueCount - RedCount,
	LandGrabSoFar = [_|LandGrabCounts],
	LandGrabCounts = [LandGrabBlueCount|LandGrabRedCount],
	LandGrabOldCount is LandGrabBlueCount - LandGrabRedCount,
	NewLandGrabCount =< LandGrabOldCount,
	getBestLandGrabCount('b',TailItems,LandGrabSoFar,LandGrab).	

getBestLandGrabCount('r',[HeadItem|TailItems],LandGrabSoFar,LandGrab):- 
	HeadItem = [_|Counts],
	Counts = [BlueCount|RedCount],
	NewLandGrabCount is RedCount - BlueCount,
	LandGrabSoFar = [_|LandGrabCounts],
	LandGrabCounts = [LandGrabBlueCount|LandGrabRedCount],
	LandGrabOldCount is LandGrabRedCount - LandGrabBlueCount,
	NewLandGrabCount > LandGrabOldCount,
	getBestLandGrabCount('r',TailItems,HeadItem,LandGrab).

getBestLandGrabCount('r',[HeadItem|TailItems],LandGrabSoFar,LandGrab):- 
	HeadItem = [_|Counts],
	Counts = [BlueCount|RedCount],
	NewLandGrabCount is RedCount - BlueCount,	
	LandGrabSoFar = [_|LandGrabCounts],
	LandGrabCounts = [LandGrabBlueCount|LandGrabRedCount],
	LandGrabOldCount is LandGrabRedCount - LandGrabBlueCount,
	NewLandGrabCount =< LandGrabOldCount,
	getBestLandGrabCount('r',TailItems,LandGrabSoFar,LandGrab).	
	
getBestLandGrabCount(_,[],LandGrab,LandGrab).

/* getMinList/3
 Return a list of each possible player move along with the count of each players pieces after the opponent
 has performed the subsequent best land-grab move and Conway's Crank has been turned. */
 getMinList(PlayerColour,CurrentBoardState,MinCountsWithMoveList):-
	findall(
		[PlayerMove,BlueCount,RedCount],
		(
			% For each player move, get the post-cranked board state...
			getPossibleMoves(PlayerColour,CurrentBoardState,PlayerPossMoves),
			member(PlayerMove,PlayerPossMoves),
			getNewBoardState(PlayerColour,PlayerMove,CurrentBoardState,PostPlayerMoveBoardState),
			next_generation(PostPlayerMoveBoardState,CrankPostPlayerMoveBoardState),
			/* For each post-cranked board state resulting from each player move, get the best opponent move.
			 Conveniently, for land_grab this is equivalent to the minimum land_grab utility value for the first player.*/
			getOpponentColour(PlayerColour,OpponentColour),
			land_grab(OpponentColour,CrankPostPlayerMoveBoardState,PostOpponentMoveBoardState,_),
			% Find the state of the board after each of these moves, and return the counts of pieces with each move.
			next_generation(PostOpponentMoveBoardState,[AliveBlue,AliveRed]),
			length(AliveBlue,BlueCount),
			length(AliveRed,RedCount)
		),
		MinCountsWithMoveList).

% getNewBoardState/4 - Get the new board state directly after a move has been made.

getNewBoardState('b',Move,[AliveBlues,AliveReds],[NewAliveBlues,AliveReds]):-
	alter_board(Move, AliveBlues, NewAliveBlues).

getNewBoardState('r',Move,[AliveBlues,AliveReds],[AliveBlues,NewAliveReds]):-
	alter_board(Move, AliveReds, NewAliveReds).

% getOpponentColour/2 - Given a player's colour, retrieve the colour of their opponent

getOpponentColour('b','r').

getOpponentColour('r','b').

%%%%%%%%%%%%%%%%%%% STRATEGY DEFINITIONS %%%%%%%%%%%%%%%%%%%%%%
			
% bloodlust/4

bloodlust(PlayerColour,CurrentBoardState,NewBoardState,Move):-
	getPossibleMoves(PlayerColour,CurrentBoardState,PossMoves),
	getPieceCountsAfterMove(PlayerColour,PossMoves,CurrentBoardState,PieceCountList),
	getSmallestOpponentCount(PlayerColour,PieceCountList,MoveWithCounts),
	MoveWithCounts = [Move|_],
	getNewBoardState(PlayerColour,Move,CurrentBoardState,NewBoardState).

% self_preservation/4

self_preservation(PlayerColour,CurrentBoardState,NewBoardState,Move):-
	getPossibleMoves(PlayerColour,CurrentBoardState,PossMoves),
	getPieceCountsAfterMove(PlayerColour,PossMoves,CurrentBoardState,PieceCountList),
	getLargestOwnCount(PlayerColour,PieceCountList,MoveWithCounts),
	MoveWithCounts = [Move|_],
	getNewBoardState(PlayerColour,Move,CurrentBoardState,NewBoardState).

% land_grab/4

land_grab(PlayerColour,CurrentBoardState,NewBoardState,Move):-
	getPossibleMoves(PlayerColour,CurrentBoardState,PossMoves),
	getPieceCountsAfterMove(PlayerColour,PossMoves,CurrentBoardState,PieceCountList),
	getBestLandGrabCount(PlayerColour,PieceCountList,MoveWithCounts),
	MoveWithCounts = [Move|_],
	getNewBoardState(PlayerColour,Move,CurrentBoardState,NewBoardState).


% minimax/4 -Two ply only

minimax(PlayerColour,CurrentBoardState,NewBoardState,Move):-
	/* Get all possible player moves, each grouped with the counts of peices that result from the
	 best subsequent land-grab move by the opponent.*/
	getMinList(PlayerColour,CurrentBoardState,MinCountsWithMoveList),
	% Now get the move with the best land-grab utility of the list that was returned.
	getBestLandGrabCount(PlayerColour,MinCountsWithMoveList,BestMoveWithCount),
	BestMoveWithCount = [Move|_],
	getNewBoardState(PlayerColour,Move,CurrentBoardState,NewBoardState).