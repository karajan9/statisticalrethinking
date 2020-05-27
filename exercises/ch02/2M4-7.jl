using DrWatson
@quickactivate "StatReth"

# %%
"""2M4
card1 = bb
card2 = bw
card3 = ww

ways to get b with card1: 2
ways to get b with card2: 1
ways to get b with card3: 0
total ways to get b: 3
otherside also black means this is card1
probability of card1 = (ways to get b with card1) / (total ways to get b) = 2/3
"""

# %%
"""2M5
card1 = bb
card2 = bw
card3 = ww
card4 = bb

ways to get b with card1: 2
ways to get b with card2: 1
ways to get b with card3: 0
ways to get b with card4: 2
total ways to get b: 5
otherside also black means this is card1 or card4
probability of card1 = (ways to get b with card1) / (total ways to get b) = 2/5
probability of card4 = (ways to get b with card4) / (total ways to get b) = 2/5
probability of either card1 or card4 = (probability of card1) + (probability of card4)
                                     = 2/5 + 2/5 = 4/5
"""

# %%
"""2M6
card1 = bb
card2 = bw
card3 = ww

ways to get b with card1: 2  |  ways to get card1: 1
ways to get b with card2: 1  |  ways to get card2: 2
ways to get b with card3: 0  |  ways to get card3: 3
total ways to get b: 4
otherside also black means this is card1
probability of card1 = (ways to get b with card1) / (total ways to get b) = 2/4
"""

# %%
"""2M7
card1 = bb
card2 = bw
card3 = ww

scenarios:

first draw: side of first draw, second draw: side of first draw -> ok/no

card1: b1, card2: b  -> no, second card not white
card1: b1, card2: w  -> ok
card1: b1, card3: w1 -> ok
card1: b1, card3: w2 -> ok

card1: b2, card2: b  -> no, second card not white
card1: b2, card2: w  -> ok
card1: b2, card3: w1 -> ok
card1: b2, card3: w2 -> ok

card2: b, card1: b1  -> no, second card not white
card2: b, card1: b2  -> no, second card not white
card2: b, card3: w1  -> ok
card2: b, card3: w2  -> ok

card2: w, card1: b1  -> no, first card not black
card2: w, card1: b2  -> no, first card not black
card2: w, card3: w1  -> no, first card not black
card2: w, card3: w2  -> no, first card not black

card3: w1, card1: b1 -> no, first card not black
card3: w1, card1: b2 -> no, first card not black
card3: w1, card2: b  -> no, first card not black
card3: w1, card2: w  -> no, first card not black

card3: w2, card1: b1 -> no, first card not black
card3: w2, card1: b2 -> no, first card not black
card3: w2, card2: b  -> no, first card not black
card3: w2, card2: w  -> no, first card not black

number of possible/ok scenarios: 8
possible scenarios with card1 as first card: 6
probability for card1 = 6/8 = 0.75
"""
