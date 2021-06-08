#!/usr/bin/ruby

class Color
    def self.natural 
        0
    end
    def self.black 
        30 
    end
    def self.red 
        31 
    end
    def self.green 
        32 
    end
    def self.yellow 
        33 
    end
    def self.blue 
        34 
    end
    def self.magenta 
        35 
    end
    def self.cyan 
        36 
    end
    def self.white 
        37 
    end
end

def color_text(text, color = Color.natural)
    if color == 0
        return text
    end
    return "\033[#{color}m#{text}\033[0m"
end

puts color_text('Hello') + color_text(' Color ', Color.red) + color_text('Ruby!', Color.white)