Chocokup
========

Chocokup is derived from [Coffeekup](http://coffeekup.org) which is a templating engine for node.js and browsers that lets you to write your HTML templates in 100% pure CoffeeScript.

What Chocokup adds is the "Panel orientation" missing from Html which is page oriented.

Chocokup introduces few new tags:

 - panel
 - box

and modifies some already existing tags:

 - body
 - header
 - footer

Using a pure Coffeescript syntax, you can write this:

    panel ->
      header -> 'header'
      footer -> 'footer'
      body ->
        for i in [0..3] 
          button "#{i}"
            
which translates into:

    div class="space">
      <div class="header space">
        <div class="content">
          header
        </div>
      </div>
      <div class="footer space">
        <div class="content">
          footer
        </div>
      </div>
      <div class="body space">
        <div class="content">
          <button>0</button>
          <button>1</button>
          <button>2</button>
          <button>3</button>
        </div>
      </div>
    </div>
    
and displays as :

<div style="position:relative;width:200px;height:200px;background-color:white;">
div class="space">
<div class="header space">
<div class="content">
header
</div>
</div>
<div class="footer space">
<div class="content">
footer
</div>
</div>
<div class="body space">
<div class="content">
<button>0</button>
<button>1</button>
<button>2</button>
<button>3</button>
</div>
</div>
</div>
</div>

&nbsp;

# Usage

----------------------------------------------------------------------------------

## Chocokup.Document

In a Coffeescript source file (ie. : mypage.coffee),  
insert an `interface` function that returns a new `Chocokup.Document`
        
    Chocokup = require 'chocolate/general/chocokup'
    
    exports.interface = ->
        new Chocokup.Document 'Chocolate.js - Wep Apps with a sweet taste', ->
            body ->
                "Welcome to Chocolatejs.org !"

            
Then open a web browser and open that page: ie. https://myserver/mypage

## Chocokup.Panel

If you only want to build a partial document, you can use `Chocokup.Panel`

    Chocokup = require 'chocolate/general/chocokup'
    
    kup = ->
        text "Welcome to Chocolatejs.org !"
        
    exports.interface = ->
        new Chocokup.Panel(kup).render()

&nbsp;

# Reference

----------------------------------------------------------------------------------

## panel

A panel is block that will expand to fill its parent's space.

### attributes: 

 - proportion: 'half', 'half-served', 'third', 'served'
 - orientation: 'horizontal', 'vertical'

### children

 - header (optional)
 - footer (optional)
 - body
 - panel

You can split it in **half**, **half-served**, **third**, or **served** using the `proportion` attribute:

 - **half**: splitted in two equal blocks
 - **half-served**: a big block followed by a small one
 - **third**: splited in three equal blocks
 - **served**: a big block, preceded and followed by two small blocks

You can orient the split with the `orientation` attribute:

 - **horizontal**
 - **vertical**

----------------------------------------------------------------------------------

## header, footer

Small block panels placed at top or bottom position inside a panel.

They are by default 32px high.

### attributes: 

 - by: 2, 3, 4, 5
 > multiply by 2, 3, 4 or 5 the header or footer height

### children

 - panel
 - box
 - usual HTML

----------------------------------------------------------------------------------

## body

Scrollable panel with default padding to put insite a panel.

### children

 - panel
 - box
 - usual HTML

----------------------------------------------------------------------------------

## box

With a box you can make a panel have thick borders inside its parent block.  
(it can now be done in HTML5 with CSS3 attribute box-sizing:border-box)

### children

 - panel
 - box

&nbsp;

----------------------------------------------------------------------------------

## totext

A function that yields a Chocokup kup as text, so that you can use it 
with Chocokup `text` function.

### Example

    text ((totext -> span "#{i}").trim() for i in [1..5]).join ''
    
will become

    <span>1</span><span>2</span><span>3</span><span>4</span><span>5</span>

instead of

    span "#{i}" for i in [1..5]

that becomes

    <span>1</span>
    <span>2</span>
    <span>3</span>
    <span>4</span>
    <span>5</span>

&nbsp;


## Samples

----------------------------------------------------------------------------------

<style>
    .demobox {
        position:relative;
        height:100px;
        background-color:white;
        border:3px grey groove;
    }
    .demobox .center, .demobox .middle {
        background-color:rgba(0,0,0,0.025);
        color:inherit;
    }
    .demobox .right, .demobox .bottom {
        background-color:rgba(0,0,0,0.05);
        color:inherit;
    }
    .demobox .header, .demobox .footer {
        background-color:rgba(0,0,0,0.1);
        color:inherit;
    }
</style>

### Panel - proportion Half

#### Horizontal orientation:

    panel proportion:"half", ->
        panel "left"
        panel "right"

<div class="demobox">
    <div class="space">
      <div class="space half horizontal left">
        <div class="space">left</div>
      </div>
      <div class="space half horizontal right">
        <div class="space">right</div>
      </div>
    </div>
</div>

#### Vertical orientation:

    panel proportion:"half", orientation:'vertical', ->
        panel "top"
        panel "bottom"

<div class="demobox">
    <div class="space">
      <div class="space half vertical top">
        <div class="space">top</div>
      </div>
      <div class="space half vertical bottom">
        <div class="space">bottom</div>
      </div>
    </div>
</div>

&nbsp;

### Panel - proportion Third

#### Horizontal orientation:

    panel proportion:"third", ->
        panel "left"
        panel "center"
        panel "right"

<div class="demobox">
    <div class="space">
      <div class="space third horizontal left">
        <div class="space">left</div>
      </div>
      <div class="space third horizontal center">
        <div class="space">center</div>
      </div>
      <div class="space third horizontal right">
        <div class="space">right</div>
      </div>
    </div>
</div>

#### Vertical orientation:

    panel proportion:"third", orientation:'vertical', ->
        panel "top"
        panel "middle"
        panel "bottom"

<div class="demobox">
    <div class="space">
      <div class="space third vertical top">
        <div class="space">top</div>
      </div>
      <div class="space third vertical middle">
        <div class="space">middle</div>
      </div>
      <div class="space third vertical bottom">
        <div class="space">bottom</div>
      </div>
    </div>
</div>

&nbsp;

### Panel - proportion Served

#### Horizontal orientation:

    panel proportion:"served", ->
        panel "aside left"
        panel "main"
        panel "aside right"

<div class="demobox">
    <div class="space">
      <div class="space service horizontal left">
        <div class="space">aside left</div>
      </div>
      <div class="space service horizontal served center">
        <div class="space">main</div>
      </div>
      <div class="space service horizontal right">
        <div class="space">aside right</div>
      </div>
    </div>
</div>

#### Vertical orientation:

    panel proportion:"served", orientation:'vertical', ->
        panel "aside top"
        panel "main"
        panel "aside bottom"

<div class="demobox">
    <div class="space">
      <div class="space service vertical top">
        <div class="space">aside top</div>
      </div>
      <div class="space service vertical served middle">
        <div class="space">main</div>
      </div>
      <div class="space service vertical bottom">
        <div class="space">aside bottom</div>
      </div>
    </div>
</div>

&nbsp;

### Panel - proportion Half-Served

#### Horizontal orientation:

    panel proportion:"half-served", ->
        panel "main"
        panel "aside"

<div class="demobox">
    <div class="space">
      <div class="space half-served horizontal left">
        <div class="space">main</div>
      </div>
      <div class="space half-served horizontal right">
        <div class="space">aside</div>
      </div>
    </div>
</div>

#### Vertical orientation:

    panel proportion:"half-served", orientation:'vertical', ->
        panel "main"
        panel "aside"

<div class="demobox">
    <div class="space">
      <div class="space half-served vertical top">
        <div class="space">main</div>
      </div>
      <div class="space half-served vertical bottom">
        <div class="space">aside</div>
      </div>
    </div>
</div>

&nbsp;

### Header

    panel ->
        header -> "header"
        body "content"

<div class="demobox">
    <div class="space">
      <div class="space header">
        header
      </div>
      <div class="space body no-footer">content</div>
    </div>
</div>

&nbsp;

### Footer

    panel ->
        footer -> "footer"
        body "content"

<div class="demobox">
    <div class="space">
      <div class="space footer">
        footer
      </div>
      <div class="space body no-header">content</div>
    </div>
</div>

&nbsp;

### Header + Footer

    panel ->
        header -> "header"
        footer -> "footer"
        body "Long content..."

<div class="demobox">
    <div class="space">
      <div class="space header">
        header
      </div>
      <div class="space footer">
        footer
      </div>
      <div class="space body">
        Long content that scrolls behind header and footer. 
        Yes it's a long content that scrolls behind header and footer.
        Absolutely, it's a long content that scrolls behind header and footer.
        Indeed, it's a long content that scrolls behind header and footer.
        Finally, it's a long content that scrolls behind header and footer.
      </div>
    </div>
</div>

&nbsp;

### Header by 2

    panel ->
        header by:2, -> "header"
        body "content"

<div class="demobox">
    <div class="space">
      <div class="space header by-2" by="2">
        header
      </div>
      <div class="space body no-footer with-2-headers">content</div>
    </div>
</div>

&nbsp;

## Chocokup CSS classes

----------------------------------------------------------------------------------

### .hidden
> element is hidden

    panel ->
        panel "default panel"
        panel "#.hidden", "option panel"
        
<div class="demobox">
    <div class="space">
      <div class="space">default panel</div>
      <div class="space hidden">option panel</div>
    </div>
</div>

    panel ->
        panel "#.hidden", "default panel"
        panel "option panel"
        
<div class="demobox">
    <div class="space">
      <div class="space hidden">default panel</div>
      <div class="space">option panel</div>
    </div>
</div>

&nbsp;

### .fullscreen
> in served panel, center panel hides left and right panels

    panel "#.fullscreen", proportion:"served", ->
        panel "left"
        panel "center"
        panel "right"
        
<div class="demobox">
    <div class="space fullscreen">
      <div class="space service horizontal left">
        <div class="space">
          left
        </div>
      </div>
      <div class="space service horizontal served center">
        <div class="space">
          center
        </div>
      </div>
      <div class="space service horizontal right">
        <div class="space">
          right
        </div>
      </div>
    </div>
</div>

&nbsp;

### .shrink 
> in half panel, makes panel size shrink to 0%   
### .expand 
> in half panel, makes panel size expand to 100%

Use .shrink and .expand together with half panel

    panel proportion:"half", ->
        panel "#", "left"
        panel "#", "right"

<div class="demobox">
    <div class="space">
      <div class="space half horizontal left">
        <div class="space">left</div>
      </div>
      <div class="space half horizontal right">
        <div class="space">right</div>
      </div>
    </div>
</div>

    panel proportion:"half", ->
        panel "#.expand", "left"
        panel "#.shrink", "right"

<div class="demobox">
    <div class="space">
      <div class="space half horizontal left expand">
        <div class="space">left</div>
      </div>
      <div class="space half horizontal right shrink">
        <div class="space">right</div>
      </div>
    </div>
</div>

    panel proportion:"half", ->
        panel "#.shrink", "left"
        panel "#.expand", "right"

<div class="demobox">
    <div class="space">
      <div class="space half horizontal left shrink">
        <div class="space">left</div>
      </div>
      <div class="space half horizontal right expand">
        <div class="space">right</div>
      </div>
    </div>
</div>

&nbsp;

### .no-header
> expands **body** panel above header when using **hidden** on header

    panel ->
        header "#.hidden",  -> "header"
        footer -> "footer"
        body "#.no-header", "content"

<div class="demobox">
    <div class="space">
      <div class="space header hidden">
        header
      </div>
      <div class="space footer">
        footer
      </div>
      <div class="space body no-header">content</div>
    </div>
</div>

&nbsp;

### .no-footer
> expands **body** panel above footer when using **hidden** on footer

    panel ->
        header -> "header"
        footer "#.hidden", -> "footer"
        body "#.no-footer", "content"

<div class="demobox">
    <div class="space">
      <div class="space header">
        header
      </div>
      <div class="space footer hidden">
        footer
      </div>
      <div class="space body no-footer">content</div>
    </div>
</div>
