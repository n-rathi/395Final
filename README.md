# About

Neha Rathi, Henry Spindell, Taylor Zheng

For this project, we decided to turn Kavi into a bartender. The player may approach Kavi and ask him things you would usually ask a bartender, such as:
<ul>
<li>Ask what he can make</li>
<li>Ask what's in a drink</li>
<li>Order a drink</li>
<li>Ask how much a drink costs</li>
</ul>

To test out the game, we suggest a sequence like the following (the first is necessary for the rest to work):
\>go to Kavi<br/>
\>what can you make?<br/>
\>what's in a seabreeze?<br/>
\>how much does a tequila_sunrise cost?<br/>
\>i'll have a bloody_mary please<br/>

And so on. Obviously the drinks are interchangeable in the final three examples, the player may query about or order anything that Kavi lists that he can make. Other grammatical structures are also accepted for these interactions; hopefully the ones that feel most natural are covered.

Most of our changes were made in grammar.prolog and imperatives.prolog, near the bottom of each file. We also added info about drinks in Ontology/drinks.prolog.
