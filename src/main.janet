(import spork/misc :as sm)

(def c-source
  '{
    :int-keyword (sequence (constant :int-keyword ) "int")
    :return-keyword (sequence (constant :return-keyword ) "return")
    :identifier (sequence (constant :identifier ) (capture (sequence (range "az" "AZ")
                          (any (choice "_"
                                       (range "az" "AZ" "09"))))))
    :open-parenthesis (sequence (constant :open-parenthesis ) "(")
    :close-parenthesis (sequence (constant :close-parenthesis ) ")")
    :open-brace (sequence (constant :open-brace ) "{")
    :integer-literal (sequence (constant :integer-literal ) (capture (some (range "09"))))
    :close-brace (sequence (constant :close-brace ) "}")
    :tokens (group (choice
            :int-keyword
            :return-keyword
            :identifier
            :open-parenthesis
            :close-parenthesis
            :open-brace
            :integer-literal
            :close-brace))
    :whitespace (set " \t\r\n\0\f\v")
    :lineender ";"
    :main
      (thru
        (some
          (choice
            :tokens
            :whitespace
            :lineender)
          ))
    })

(defn oopspage [& args]
	(print "Usage: jpc foo.c [-out foo.s] [-h]"))

(defn finaly
  [outfile-name outbuffer]
  #(spit outfile-name outbuffer)
  )

(defn main [& args]
  (pp args)
  (cond
  	(or (< (length args) 2)
  			(= "-h" (get args 1)))
    	(oopspage ;args)
    (if-let [first-arg (get args 1)
    				 its-a-string (string? first-arg)
    				 its-a-path--lstat-result (os/lstat (get args 1))
    				 its-a-file (= :file (its-a-path--lstat-result :mode))
    				 its-a-cfile (string/has-suffix? ".c" first-arg)
    				 c-source-inbuffer (slurp first-arg)
    				 outbuffer (buffer/new-filled 0x00 (length c-source-inbuffer))
    				 outfile-name (string (sm/trim-suffix ".c" first-arg) ".s")]
    	(defer (finaly outfile-name outbuffer)
    		(print c-source-inbuffer)
        (pp (peg/match c-source c-source-inbuffer))
    		(buffer/push-string outbuffer c-source-inbuffer))
    	nil)
    (pp :done)))