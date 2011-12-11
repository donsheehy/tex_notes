
header = "<html>
  <head>
    <link href='http://fonts.googleapis.com/css?family=Crimson+Text:400,400italic' rel='stylesheet' type='text/css'>
    <link rel=\"stylesheet\" href=\"style.css\" type=\"text/css\" media=\"screen\" charset=\"utf-8\">
    <script type='text/x-mathjax-config'>
      MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});
    </script>
    <script src='http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML' type='text/javascript'></script>

  </head>
  <body>
    <div id='page'>"
    
footer = "
        </div>
      </body>
    </html>"    

puts header

ARGF.each do |line|
  line.sub!(/.*\\begin\{(\w*)\}/, "<div class=\"\\1\"><h3>\\1</h3>")
  line.sub!(/.*\\end\{\w*\}/, '</div>')
  line.sub!(/\\label\{(\w*):(\w*)\}/, "<a href=\"\\1_\\2\"></a>")
  line.sub!(/.*\%.*/, '')  
  puts line
end

puts footer

