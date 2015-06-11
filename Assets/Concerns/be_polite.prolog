%%%
%%% Be_polite concern
%%% Causes character to initiate conversations with any character
%%% who comes into this character's social space.
%%%

% Currently disabled because it's annoying to have your character constantly
% get into pointless conversations.
%standard_concern(be_polite, 1).

score_action(greet(_, _), be_polite, _, 50).

