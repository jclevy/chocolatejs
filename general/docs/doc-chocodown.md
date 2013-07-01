# Chocodown

Chocodown is a slightly enhanced javascript port of Markdown based on showdown.js which is a javascript port of Markdown.

You can read Markdown documentation in Doccolate help section.

With Chocodown you can insert javascript, coffeescript, chocokup, html and css blocks that will be
highlighted following their syntax. 

Furthermore their code can be executed while parse.

There is a Chocodown section in the Lab where you can interactively
create web interfaces using javascript, coffeescript, chocokup, html and css.

Example:

\#! css

    #! css
    .chocodown-demo-panel {
        position:relative;
        width:200px;
        height:150px;
        background-color:white;"
    }
&nbsp;

\#! chocokup

    #! chocokup
    panel ".chocodown-demo-panel", ->
        panel ->
            header -> "header"
            footer -> "footer"
            body ->
                input type:"button", value: 'Ok'
