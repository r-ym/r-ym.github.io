---
layout: project
title: Random note generator on the homepage
date: 2020-06-24 01:44 +0900
link: true
---

Navigate to the Home page for me real quick in a different tab. If on mobile press the hyperlink in the mobile, hover if you are on laptop. The link changes to a note from the Notes section of this site. Press outside the box, or hover outwards and repeat. Every iteration hopefully links to a different Note. Given the low number, and lack of text in almost all of them the links are bound to repeat. I intend to remedy that soon. The effect was achieved with Liquid and JavaScript in tandem. Liquid to access Jekyll's underlying Collection variables into an array, which JavaScript can iterate thru with random indexing.

Two arrays are generated, one with the title of the note for the text, and the other with its url.

The hover patterns are handled by the JavaScript below.
```
<h1 class="post-title">
    {{ site.description }} <div id='url' onmouseenter="changeText()" onmouseleave="changeback()" style = "text-decoration:underline;">a conditional form</div>
</h1>
```

"Musings on a conditional form" comes from the nonsensical title of 1975's new album "Notes On A Conditional Form". The 'Conditional Form' is what caught my attention because of the potential in it's ambiguity.

