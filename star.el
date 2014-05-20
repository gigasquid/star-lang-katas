;;; 
;;; StarEmacs mode
;;; Copyright (C) 2012/2013 F.G. McCabe

;;; Originally based on april mode authored by J. Knottenbelt

;;; Keywords: languages

;;; GNU Emacs is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2, or (at your option)
;;; any later version.

;;; GNU Emacs is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.

;;; You should have received a copy of the GNU General Public License
;;; along with GNU Emacs; see the file COPYING.  If not, write to the
;;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;;; Boston, MA 02111-1307, USA.

;;; Commentary

(require 'cl)
(require 'font-lock)

(defvar
  star-xemacs (not (not (string-match "XEmacs" (emacs-version))))
  "Whether star-mode is running under XEmacs or not")

;; Customization parameters

(defgroup star nil
  "Major mode for editing and running Star under Emacs"
  :group 'languages)

(defcustom star-block-indent 2
  "* Amount by which to indent blocks of code in Star mode"
  :type 'integer
  :group 'star)

(defcustom star-paren-indent 2
  "* Amount by which to indent after a left paren in Star mode"
  :type 'integer
  :group 'star)

(defcustom star-brace-indent 2
  "* Amount by which to indent after a left brace in Star mode"
  :type 'integer
  :group 'star)

(defcustom star-bracket-indent 2
  "* Amount by which to indent after a left bracket in Star mode"
  :type 'integer
  :group 'star)

(defcustom star-arrow-indent 2
  "* Amount by which to indent after an arrow in Star mode"
  :type 'integer
  :group 'star)

(defcustom star-query-indent 2
  "* Amount by which to indent after an query in Star mode"
  :type 'integer
  :group 'star)

(defcustom comment-column 40
  "* The column where -- comments are placed"
  :type 'integer
  :group 'star)

;;; Initialise the syntax table

(defun star-modify-syntax (table &rest pairs)
  (while pairs
    (modify-syntax-entry (car pairs) (cadr pairs) table)
    (setq pairs (cddr pairs))))

(defvar star-mode-syntax-table nil
  "Syntax table used while in Star mode.")

(if star-mode-syntax-table 
    nil
  (setq star-mode-syntax-table (make-syntax-table))
  ;; Comments
  (star-modify-syntax star-mode-syntax-table
		    ?/   ". 14"
		    ?*   ". 23"
		    ?\n  (if star-xemacs ">78b" ">56b"))
  ;; Symbols
  (star-modify-syntax star-mode-syntax-table
		    ?_   "w"
		    ?!   "_"
		    ?@   "_"
		    ?#   "_"
		    ?%   "_"
		    ?+   "_"
		    ?=   "_"
		    ?<   "_"
		    ?>   "_"
		    ?=   "_"
		    ?~   "_"
		    ?-   "_"
		    ?$   "_"
		    ?&   "_"
		    ?|   "."
		    ?\'  "_"
		    ?\"  "\""
		    ?\`  "\""
		    ?^   "_"
		    ?\;   "."
		    ?    "    "
		    ?\t  "    "))

;;; Initialise the abbrev table
(defvar star-mode-abbrev-table nil
  "Abbrev table used while in Star mode.")
(define-abbrev-table 'star-mode-abbrev-table ())

(defun mode-char-position () (format "%s" (point)))

(defun set-star-mode-line ()
  "modify mode line with absolute char position"
  (setq mode-line-format 
	(replace-el mode-line-format 'mode-line-position 'mode-char-position))
)

(defun replace-el (l e r)
  "replace element e in l with r"
  (cond ((null l) (cons r l))
	((eq (car l) e) (cons r (cdr l)))
	((eq (car l) r) l)
	(t (cons (car l) (replace-el (cdr l) e r)))))

;;; Initialise the key map
(defvar star-mode-map nil)

(defun setup-star-mode-map ()
  (progn
    (if (null star-mode-map)
	(setq star-mode-map (make-sparse-keymap))
      (define-key star-mode-map "\t" 'indent-for-tab-command)
      (define-key star-mode-map [(control meta q)] 'star-indent-sexp)
      (define-key star-mode-map [(control c) (control c)] 'comment-region)
      ;;  (define-key star-mode-map [(control c) (control d)] 'stardebug-buffer)
      (define-key star-mode-map [(control meta r)] 'star-reload)
      (mapcar '(lambda (key-seq)
		 (define-key star-mode-map 
		   key-seq 
		   'star-self-insert-and-indent-command))
	      '("{" "}" ";" "," "(" ")" "[" "]")))
    (use-local-map star-mode-map)
))

(defun star-self-insert-and-indent-command (n)
  "Self insert and indent appropriately"
  (interactive "*P")
  (self-insert-command (prefix-numeric-value n))
  (indent-for-tab-command))

;; star-indent-cache holds the parse state 
;; at particular points in the buffer.
;; It is a sorted list (largest points first)
;; of elements (POINT . PARSE-STATE)
;; PARSE-STATE are cells (STATE . STACK)
(defvar star-indent-cache nil
  "Incremental parse state cache")

(defun clear-indent-cache ()
  (interactive "")
  (setq star-indent-cache nil))

;;; Provide `star-mode' user callable function
(defun star-mode ()
  "Major mode for editing Star programs"
  (interactive)
  (kill-all-local-variables)

  (setup-star-mode-map)
  (setq mode-name "Star")
  (setq major-mode 'star-mode)

  (setq local-abbrev-table star-mode-abbrev-table)
  (set-syntax-table star-mode-syntax-table)

  (make-local-variable 'comment-start)
  (setq comment-start "-- ")

  (make-local-variable 'comment-end)
  (setq comment-end "")

  (make-local-variable 'parse-sexp-ignore-comments)
  (setq parse-sexp-ignore-comments t)

  ;; Local variables (indentation)
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'star-indent-line)

  ;; very important that case-fold-search is nil
  ;; since star is a case-sensitive language
  (setq case-fold-search nil)

  (make-local-variable 'star-indent-cache)
  (setq star-indent-cache nil)

  ;; After a buffer change, we need
  ;; to ensure that the cache is consistent.
  (make-local-variable 'before-change-functions)
  (add-to-list 'before-change-functions 'star-before-change-function)

  ;; Initialise font-lock support

  (star-init-font-lock)
  (run-hooks 'star-mode-hook))

(defun star-before-change-function (from to &rest rest)
  ;; The buffer has changed, we need to
  ;; remove any parse states that have been saved
  ;; past point 'from' in the buffer.
  (while (and star-indent-cache
	      (>= (caar star-indent-cache) from))
    (setq star-indent-cache (cdr star-indent-cache))))

;;; Indentation and syntax
(defsubst star-skip-block-comment ()
  (forward-comment 1))

(defsubst star-skip-line-comment ()
  (search-forward "\n"))

(defsubst star-skip-string ()
  (goto-char (or (scan-sexps (point) 1) (buffer-end 1))))

(defsubst star-skip-symbol ()
  (goto-char (or (scan-sexps (point) 1) (buffer-end 1))))

(defsubst star-skip-char ()
  (cond ((looking-at "'\\\\[uU][0-9a-fA-F]+;'")
	 (goto-char (match-end 0)))
	((looking-at "'\\\\.'")
	 (goto-char (match-end 0)))
	((looking-at "'.'")
	 (goto-char (match-end 0)))
	(t (forward-char 3))))

(defun star-calculate-outer-indent (pos)
  (save-excursion
    (condition-case nil
	(progn (goto-char pos)
	       (goto-char (scan-lists pos -1 1))
	       (star-calculate-indent (point)))
      (error 0))))

;;; look for a the first non-whitespace
(defun star-indentation-level (pos)
  "returns the indentation level of the current line"
  (save-excursion
    (goto-char pos)
    (beginning-of-line)
    (skip-chars-forward " \t")
    (current-column)))

(defun star-line-get-pos-after (pos what)
  (save-excursion
    (goto-char pos)
    (beginning-of-line)
    (skip-chars-forward " \t")
    (if (looking-at what)
	(match-end 0)
      nil)))

(defun star-one-of (&rest l)
  (if (cadr l) 
      (concat (car l) "\\|"
	      (apply 'star-one-of (cdr l)))
    (car l)))

(defvar star-close-par (star-one-of ")#" "]" ")" "}" "|>")
  "Star close parentheses")

(defvar star-line-comment "-- "
  "Star line comment")

(defvar star-body-comment "/\\*"
  "Star body comment")

(defvar star-comment (concat "\\(" 
			   (star-one-of star-line-comment star-body-comment)
			   "\\)")
  "Star comment")

(defvar star-comment-bol (concat "^" star-comment)
  "Star comment at beginning of line")

(defconst star-comment-start-skip "^-- \\|[^:]-- ")

;;; Parse tables
(defconst star-operators
  ;; Prec Text  Regex  Push Pop Hanging Delta
  '(
    (2000 "{"   "{"    t    nil  nil    star-brace-indent)
    (2000 "}"   "}"    nil  same  nil	0)

    (1900 ";"   ";"    t    same    nil	0)

    (2000 "#("   "#("  t    t  nil	star-paren-indent)
    (2000 ")#"   ")#"  nil  same nil	0)


    (1200 "("   "("    t    t  nil	star-paren-indent)
    (1200 ")"   ")"    nil  same nil	0)

    (1000 "["   "\\["  t    t  nil	star-bracket-indent)
    (1000 "]"   "\\]"  nil  same nil	0)

    (1000 "<|"  "<|"   t    t  nil	star-paren-indent)
    (1000 "|>"  "|>"   nil  same nil	0)

    (1200 "is"  "\\<is\\>"  t  t  star-arrow-indent 0)

    (1200 "do"  "\\<do\\>"  t    t  star-arrow-indent	0)
    (1200 "where" "\\<where\\>"  nil    t  star-arrow-indent	0)
    (1200 ":="  ":="   nil    t    star-arrow-indent 0)
    (1100 "then"  "\\<then\\>"  t    nil   star-block-indent 0)
    (1100 "else"  "\\<else\\>"  nil  same  star-block-indent 0)
    (1199 "<=>"  "<=>" t    t    star-arrow-indent 0)
    (1199 "=>"  "=>"   t    t    star-arrow-indent 0)
    (1199 "<="  "<="   t    t    star-arrow-indent 0)
    (1100 "'s"  "\\<'s\\>"  nil    nil  star-arrow-indent	  0)
    (1100 "'n"  "\\<'n\\>"  nil    nil  star-arrow-indent	  0)
    (1200 "or"  "\\<or\\>"  t    same  star-arrow-indent  star-arrow-indent)
    (1000 ","   ","    t    t    star-bracket-indent 0)
    (1040 "?"   "\\?"  t    t    nil star-query-indent)
    )
  "Star operators and precedences")

;;; Speed up table lookups by encoding
;;; information in operator symbols.
(defun star-setup-operators-hash ()
  (interactive)
  (let ((l star-operators))
    (while l 
      (let* ((o (car l))
	     (precedence (first o))
	     (text (second o))
	     (regex (third o))
	     (push (fourth o))
	     (pop  (fifth o))
	     (hanging (sixth o))
	     (delta (seventh o))
	     (symbol (intern text)))
	(put symbol 'precedence precedence)
	(put symbol 'text text)
	(put symbol 'regex regex)
	(put symbol 'push push)
	(put symbol 'pop (if (eq pop 'same) nil pop))
	(put symbol 'pop-until-same (eq pop 'same))
	(put symbol 'hanging hanging)
	(put symbol 'delta delta)
	(put symbol 'length (length text)))
      (setq l (cdr l)))))
(star-setup-operators-hash)

;;; Regular expression matching important operators
(defconst star-operators-regex
  (apply 'star-one-of
	 (mapcar 'caddr star-operators))
  "Regular expression matching important operators")

(defconst star-escaped-string-regex "\\\\['\"]"
  "Regular expression matching the start of an escape")

(defconst star-next-token-regex
  (star-one-of star-operators-regex 
	       star-escaped-string-regex
	       "\""
	       "\'"
	       star-body-comment
	       star-line-comment))

;; The PARSE-STATE is a stack with at least one element.
;; Each element is a list with format (PRECEDENCE OP INDENT)
;; PREC: operator precedence
;; OP: symbol corresponsing to that operator
;; INDENT: indent calculated so far.
(defsubst star-init-parse-state ()
  (list 
   (list 9999 'none 0 nil)))

;; Accessor functions for a PARSE-STATE ((PREC OP INDENT) . STACK)
(defun star-parse-state-indent (parse-state)
  (third (car parse-state)))

(defun star-parse-state-op (parse-state)
  (second (car parse-state)))

(defun star-parse-state-in-comment (parse-state)
  (fourth (car parse-state)))

(defun star-parse-until (pos)
  ;; Find the most recent parse state in the cache 
  (star-debug "parsing to %s\n" pos)
  ;; that is <= pos
  (let ((parse-state (star-init-parse-state)) ; The parse-state just before POS
	(parse-pos   1)			; The position of the above parse-state
	(before      star-indent-cache)   ; All the parse-states before POS
	(after       nil))		; All the parse-states after POS

    (star-debug "look for %d in cache \n" pos)
    (while (and before
		(> (caar before) pos))
      (progn
	(setq after (cons (car before) after)
	      before (cdr before))))

    ;; Load the parse state
    (if before
	(setq parse-pos (caar before)
	      parse-state (cdar before)
	      before (cdr before)))

    (star-debug "parse state is %s parse from %d \n" parse-state parse-pos)

    (cond 
     ;; Have we already parsed up till here?
     ((= parse-pos pos)		
      parse-state)
     ;; Nope
     (t 
      ;; if there is an error parsing (eg. due to end-of-buffer)
      ;; just return 0
      (condition-case nil
	  (let ((new-parse-state (star-parse parse-pos pos parse-state)))
	    (star-debug "new parse state from %s is %s\n" parse-pos new-parse-state)
	    ;; If we parsed into a comment
	    ;; don't bother saving the parse state.
	    (if (star-parse-state-in-comment new-parse-state)
		new-parse-state
	      (progn
		;; Insert the new-parse-state into the indent-cache
		;; Cache is sorted, largest first.
		;; cache = (reverse after) <> [new-parse-state,parse-state,..before]	
;		(star-debug "cache before change: %s\n" star-indent-cache)
		(setq star-indent-cache
		      (cons (cons parse-pos parse-state) 
			    before))
		(setq star-indent-cache
		      (cons (cons pos new-parse-state)
			    star-indent-cache))
		(while after
		  (setq star-indent-cache (cons (car after) star-indent-cache)
			after (cdr after)))
		new-parse-state)))
	(t ;; Some error occurred
	 parse-state)))
     )))

(defsubst star-calculate-brace-indent (pos)
  (star-parse-state-indent (star-parse-until pos)))

;;; Parse from POS to TO given initial PARSE-STATE
;;; Return final PARSE-STATE at TO.
(defun star-parse (pos to parse-state)
  (let* ((case-fold-search nil)
	 (state (car parse-state))
	 (stack (cdr parse-state))
	 (tos-prec   (first  state))
	 (tos-op     (second state))
	 (tos-indent (third  state))
	 (tos-in-comment (fourth state)))
    (save-excursion
      (star-debug "parsing from %s\n" pos)
      (star-debug "state is %s\n" state)
      (star-debug "stack is %s\n" stack)

      (goto-char pos)
      ;; We assume that the parsing does not
      ;; resume from within a (block) comment.
      ;; To implement that we would need
      ;; to check tos-in-comment and scan for
      ;; end-of-comment (*/) to escape it first.
      (progn 
	(while (< (point) to)
	  (cond 
	   ;; An important Star operator
	   ((looking-at star-operators-regex)
	    (let* ((symbol (intern (match-string 0)))
		   (symbol-prec (get symbol 'precedence)))

	      (star-debug "got operator [%s]/%s @ %s\n" symbol symbol-prec (point))
	      (if (get symbol 'pop)
		  ;; Check to see if we should pop any operators off the stack
		  (while (< tos-prec symbol-prec)
		    (star-debug "popping %s\n" (car stack))
		    (setq state (car stack)
			  stack (cdr stack)
			  tos-prec   (first state)
			  tos-op     (second state)
			  tos-indent (third state))))
		
	      (if (get symbol 'pop-until-same)
		  ;; pop of all operators until
		  ;; we meet an operator with the same
		  ;; precedence (for brackets)
		  (progn
		    (while (and (< tos-prec symbol-prec) (cdr stack))
		      (star-debug "pop stack %s\n" (car stack));
		      (setq state (car stack)
			    stack (cdr stack)
			    tos-prec   (first state)
			    tos-op     (second state)
			    tos-indent (third state)))
		    (if (= tos-prec symbol-prec)
			(progn 
			  (setq state (car stack)
				stack (cdr stack)
				tos-prec   (first state)
				tos-op     (second state)
				tos-indent (third state))))))

	      (if (get symbol 'push)
		  ;; Push the symbol onto the stack, if allowed
		  (progn
		    (star-debug "push state %s %s %s\n"
				tos-prec tos-op tos-indent)
		    (setq 
		     ;; Save the old state
		     state (list tos-prec 
				 tos-op 
				 tos-indent)
		     ;; Push it onto the stack
		     stack (cons state stack)
		     ;; New top-of-stack (indentation carries on from before)
		     tos-prec   symbol-prec
		     tos-op     symbol)))

	      (star-debug "after operator, parse stack is %s, current %s %s %s\n" stack tos-prec tos-op tos-indent)
	    
	      ;; Advance the pointer 
	      (forward-char (get symbol 'length))

	      ;; Adjust the indentation for hanging

	      (if (and (get symbol 'hanging)
		       (or (looking-at star-font-lock-comment-regexp)
			   (looking-at "[ \t]*$")))
		  ;; Hanging
		  (progn 
		    (star-debug "hanging %s at %s\n" symbol (point))
		    (setq tos-indent (+ tos-indent
					(eval (get symbol 'hanging))))
		    (star-debug "hung indent %s\n" tos-indent))
		;; Not Hanging
		(if (get symbol 'delta)
		    (setq tos-indent (+ tos-indent 
					(eval (get symbol 'delta))))))
	      ))
	   ;; Skip syntax
	   ((looking-at star-line-comment)
	    (star-skip-line-comment))
	   ((looking-at star-body-comment)
	    (let ((co-col (current-column)))
	      (star-skip-block-comment)
	      (if (>= (point) to)
		  (setq tos-indent (1+ co-col)
			tos-in-comment t))))
	   ((looking-at star-escaped-string-regex)
	    (forward-char 2)) ;; fix me.
	   ((looking-at "\"")
	    (star-skip-string))
	   ((looking-at "\'")
	    (star-skip-char))
	   ((looking-at " \t\n")
	    (skip-chars-forward " \t\n"))

	   ((search-forward-regexp star-next-token-regex to t)
	    (goto-char (match-beginning 0)))
	    ;; It might be better to forward char first and then scan
	    ;; for the next token to eliminate any possibility of
	    ;; an un-handled token.
	    (t
	     (forward-char))
		))

	;; Save the state for future runs
	(setq state (list tos-prec 
			  tos-op 
			  tos-indent
			  tos-in-comment))
	(star-debug "stack: %s %s\n" state stack)
	(cons state stack)))))

(defun star-calculate-indent (pos)
  (save-excursion
    (goto-char pos)
    (skip-chars-forward " \t")
    
    (cond
     ;; Keep comments at beginning of line at the beginning
     ((looking-at star-comment-bol)
      0)

     ;; If it's a close brace then we can short-cut (a bit)
     ((looking-at star-close-par)
      (star-calculate-outer-indent (point)))

      ;; Otherwise standard indent position
     (t (star-calculate-brace-indent (point))))))

(defun star-goto-first-non-whitespace-maybe ()
  (let ((dest (save-excursion
		(beginning-of-line)
		(skip-chars-forward " \t")
		(point))))
    (if (< (point) dest)
	(goto-char dest))))

(defvar star-debugging nil
  "Non-nil if should log messages to *star-debug*")

(defun star-debug (msg &rest args)
  "Print a debug message to the *star-debug* buffer"
  (if star-debugging
      (save-excursion
	(set-buffer (get-buffer-create "*star-debug*"))
	(end-of-buffer)
	(insert (apply 'format msg args)))))

(defun clear-star-debug ()
  (interactive)
  (if star-debugging
      (save-excursion
	(set-buffer (get-buffer-create "*star-debug*"))
	(erase-buffer)
	;;(clear-indent-cache)
	)))

;;; Hook called when the tab key is pressed
(defun star-indent-line ()
  (save-excursion
    (clear-star-debug)

    (let* ((bol         (progn (beginning-of-line) (point)))
	   (cur-level   (star-indentation-level bol))
	   (level       (star-calculate-indent (point))))
      (if (= cur-level level)
	  nil
	(progn
	  (delete-horizontal-space)
	  (indent-to level)
	  (star-readjust-comment bol)
	  ))))
  (star-goto-first-non-whitespace-maybe))

;;; Readjust a -- comment on the same line
;;; (not used for now)
(defun star-readjust-comment (pos)
  "readjust a line comment if there is one on the current line"
  (save-excursion
    (let
	((bol (progn (goto-char pos)(beginning-of-line)(point)))
	 (eol (progn (goto-char pos)(end-of-line)(point))))
      (goto-char bol)
      (cond ((search-forward-regexp star-comment-start-skip eol t)
	     (indent-for-comment))))))

(defun star-indent-sexp ()
  (interactive)
  (save-excursion
    (let (;(start  (point))
	  (stop   (condition-case nil
		      (save-excursion (forward-sexp 1) (point))
		    (error (point)))))
      (while (and (< (point) stop)
		  (progn (star-indent-line) t)
		  (eq (forward-line) 0)))
      (star-indent-line))))

;;; Font-lock support

(defvar star-font-lock-keyword-regexp 
  (concat "\\<\\("
	  (star-one-of 
	   "action"			; control
	   "alias"			; type
	   "and"			; control
	   "all"			; query
	   "any of"			; query
	   "as"				; control
	   "assert"			; assert action/statement

	   "by"				; query

           "case"                       ; control
	   "cast"			; control
	   "catch"			; control
	   "contract"			; contract 

	   "counts as"			; type witness

	   "default"			; control
	   "delete"			; CRUD control
	   "descending"			; query
	   "determines"			; type constraint
	   "do"				; control
	   "down"			; control

	   "else"			; control
	   "extend"			; CRUD control

	   "for all"			; type
	   "for"			; control
	   "from"			; control

	   "has kind"			; control
	   "has type"			; control

	   "if"				; control
	   "ignore"			; control
	   "implementation"		; contracts
	   "implements"			; type constraint
	   "implies"			; control
	   "import"			; package
	   "in"				; control
	   "is"				; control

	   "java"			; control

	   "let"			; control

	   "matching"			; control
	   "matches"			; control
	   "memo"			; control
	   "merge"			; CRUD control

	   "'n"				; control
	   "not"			; control

	   "of"				; control
	   "or"				; control
	   "order"			; query
	   "otherwise"			; query
	   "over"			; type

	   "present"			; CRUD control
           "private"                    ; non-exported element

	   "quote"			; control

	   "raise"			; control
	   "reduction"			; query
	   "remove"			; CRUD control
	   "ref"			; type

	   "'s"				; control
	   "spawn"			; control
	   "such that"			; type
           "sync"

	   "task"			; control
	   "then"			; control
	   "this"			; this object
	   "to"				; control
	   "try"			; control
	   "type"			; control

	   "unique"			; query
	   "unquote"			; control
	   "update"			; CRUD control
	   "using"			; control

	   "valof"			; control
	   "valis"			; control
	   "var"			; control

	   "when"			; control
	   "where"			; control
	   "while"			; control
	   "with"			; control
           )
	  "\\)\\>")
  "Regular expression matching the keywords to highlight in Star mode")

(defvar star-font-lock-std-regexp 
  (concat "\\<\\("
	  (star-one-of 
	   "arithmetic"			; standard contract
	   "array"			; type

	   "boolean"			; type

	   "char"			; type
	   "comparable"			; standard contract
	   "cons"			; type

	   "equality"			; standard contract

	   "false"			; standard enumeration symbol
	   "float"			; type 

	   "hash"			; maps

	   "integer"			; type 

	   "list"			; type
	   "long"			; type

	   "map"			; standard type

	   "relation"			; type

	   "string"			; type

	   "thread"			; type
	   "true"			; standard enumeration symbol

	   "void"			; type
           )
	  "\\)\\>")
  "Regular expression matching the standard built-in names")


(defvar star-font-lock-symbol-regexp
  (concat "\\("
	  (star-one-of 
	   "::="
	   "\\$="
	   "\\$"
	   "=>"
	   "-->"
	   ":--"
	   "->"
	   "<="
	   "{\\."
	   "\\.}"
	   "\\.\\."
	   ":="
	   "\\.="
	   "%="
	   ">="
	   "=="
	   "=<"
	   "="
	   "<\\~"
	   "<>"
	   "\\*>"
	   "::="
	   "::"
	   ":"
	   "%%"
	   "~"
	   "@="
	   "@>"
	   "@@"
	   "@"
	   "#"
	   "\\^"
	   "\\^\\^"
	   ",\\.\\."
	   "!\\."
	   "\\."
	   "!"
	   "+"
	   "-")
	  "\\)")
  "Regular expression matching the symbols to highlight in Star mode")

(defvar star-font-lock-function-regexp
  "^[ \t]*\\(\\sw+\\)([0-9_a-zA-Z?,.:`'\\ ]*)[ \t]*\\(is\\|do\\)"
  "Regular expression matching the function declarations to highlight in Star mode")

(defvar star-font-lock-include-regexp
  "import[ \t]+"
  "Regular expression matching the compiler import package statement")

(defvar star-font-lock-comment-regexp-bol
  "^\\(--[ \t].*$\\)")

(defvar star-font-lock-comment-regexp
  "[^:]\\(--[ \t].*$\\)")

;; Match a line comment, not inside a string.
(defun star-match-line-comment (limit)
  (let ((from (save-excursion (beginning-of-line) (point))))
    (if (search-forward-regexp star-font-lock-comment-regexp limit t)
	(let ((state (parse-partial-sexp from (match-beginning 1))))
	  (if state
	      (if (nth 3 state)
		  (star-match-line-comment limit)
		t)
	    t)))))

(defconst star-dot-space (intern ". "))
(defconst star-dot-newline (intern ".\n"))
(defconst star-dot-tab (intern ".\t"))

(defun star-match-function (limit)
  (if (search-forward-regexp "^[ \t]*\\(\\sw+\\)[ \t]*" limit t)
      (let* ((s (save-excursion 
		  (save-match-data 
		    (star-parse-until (progn (beginning-of-line) (point))))))
	     (op (star-parse-state-op s)))
	(cond
	 ((and (eq op '\{) (cdr s)
	       (not (eq (star-parse-state-op (cdr s)) 'action)))
	  t)
	 ((or (eq op star-dot-space) 
	      (eq op star-dot-newline)
	      (eq op star-dot-tab))
	  t)
	 (t
	  (star-match-function limit))))))

(defconst star-font-lock-keywords-1
  `((,star-font-lock-comment-regexp-bol (1 font-lock-comment-face))
    (,star-font-lock-comment-regexp     (1 font-lock-comment-face))
;;    (star-match-line-comment (1 font-lock-comment-face))
    (,star-font-lock-keyword-regexp     (1 font-lock-keyword-face))
    (,star-font-lock-symbol-regexp      (1 font-lock-reference-face))
    (,star-font-lock-std-regexp         (1 font-lock-builtin-face))
;;;    (,star-font-lock-include-regexp     (1 font-lock-doc-string-face))
    (,star-font-lock-function-regexp    (1 font-lock-function-name-face))
    (star-match-function     (1 font-lock-function-name-face t))
    ))

(defvar star-font-lock-keywords star-font-lock-keywords-1
  "Keywords to syntax highlight with font-lock-mode")

(defun star-init-font-lock ()
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults '(star-font-lock-keywords nil nil nil nil)))

(provide 'star)
