(declare-project 
  :name "janet's peggin' compiler"
  :description "following https://norasandler.com/2017/11/29/Write-a-Compiler.html this is an attempt to write a c to assembly transpiler"
  :url "https://github.com/kamisori/janets-peggin-compiler"
  :author "Pia Janet Brüll <mlatu@mlatu.de>")

(declare-executable
  :name "jpc"
  :entry "./src/main.janet")


(defn test-file
  [filename path]
  (let [filepath (string path "/" filename)]
    (os/execute ["build/jpc" filepath] :p)))

(defn test-folder
  [path]
    (each f (os/dir path)
      (test-file f path)))

(defn test-stage [stage-path]
    (test-folder (string stage-path "/valid"))
    (test-folder (string stage-path "/invalid")))

(defn test-compiler [test-programs-path]
  (let [paths (map |(string test-programs-path "/stage_" $0) (range 1 10))]
  (each p paths
    (test-stage p))))

# `jpm run repl` to run a repl with access to jaylib
(phony "tst" ["build"]
  (let [path "./write_a_c_compiler"]
    (test-compiler path)
  )
)