#!/usr/bin/env ruby

require 'rubygems'
require 'erb'
require 'haml'
require 'tilt'

Dir.chdir(ENV['PWD'])
HERE = File.expand_path(File.dirname(__FILE__))
MACROS = File.join(HERE, 'macros.tex')
LAYOUT = File.join(HERE, 'marked_layout.html.erb')

output = ""
macros = []
paragraph_state = :none

IO.foreach(MACROS) do |line|
  md = line.match(/newcommand\{(\\[a-zA-Z]*)\}\{(.*)\}/)
  if md
    macros << [md[1], md[2]]
    line = ''
  end
end

ARGF.each do |line|
  
  # Do replacements for macros
  macros.each do |m|
    while (md = line.match(/(#{"\\" + m[0]})[^a-zA-Z]/))
      if md
        line.sub!(m[0],m[1])
      end
    end
  end

  # Handle list environments
  line.sub!('\begin{itemize}','<ul>')
  line.sub!('\end{itemize}','</ul>')
  line.sub!('\begin{enumerate}','<ol>')
  line.sub!('\end{enumerate}','</ol>')
  line.sub!('\item','<li>')
  
  # Math environemnts that become divs
  %w{theorem lemma corollary definition observation remark proposition proof}.each do |env|
    line.sub!(/\\begin\{#{env}\}/, "<div class=\'#{env}\'><h3>#{env.capitalize}.</h3>")
    line.sub!(/\\end\{#{env}\}/, '</div>')
  end

  # Text environments that become divs
  %w{section subsection subsubsection abstract}.each do |env|
    line.sub!(/\\#{env}\*?\{(.*)\}/, "<div class=\'#{env}\'><h2>\\1</h2>")
  end

  %w{textbf texttt textsc emph}.each do |style|
    line.gsub!(/\\#{style}\{([^\}]*)\}/, "<span class='#{style}'>\\1</span>")
  end

  # Whitespace and quotation marks
  line.sub!(/``/, "&#8220;")
  line.sub!(/''/, "&#8221;")
  line.sub!(/\\\s/, " ")
  
  # Labels
  line.sub!(/\\label\{(\w*):(\w*)\}/, "<a href=\"\\1_\\2\"></a>")

  # Strip comments
  line.sub!(/(.*)\%.*/, "\\1")
  
  # Paragraphs
  empty_line = (line =~ /^\s*$/)
  case [paragraph_state, empty_line]
    when [:none, empty_line]
      paragraph_state = :starting
    when [:during, 0]
      line = "</p>\n"
      paragraph_state = :starting
    when [:starting, nil]
      paragraph_state = :during
      line.insert(0, "<p>\n")
  end

  output << line
end

template = Tilt.new(LAYOUT)
puts template.render{output}
