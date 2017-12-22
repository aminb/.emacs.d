;;; private/amin/+bindings.el -*- lexical-binding: t; -*-

(map!
 "C-s" #'swiper
 "C-S-l" #'recenter
 "C-x C-b" #'ibuffer
 [C-S-return] #'recompile
 :n "gl" #'recenter
 :n "/" #'swiper
 ;; "C-=" #'count-words-region
 (:leader
   :n "cq" #'fill-paragraph
   :n "ca" #'auto-fill-mode
   :n "cc" #'count-words-region
   )
 (:leader
   :desc "dashboard" :n "d" #'+doom-dashboard/open
   :desc "Centered Window Mode" :n "C" #'centered-window-mode
   (:desc "Dumb Jump" :prefix "j"
     :desc "Go" :n "j" #'dumb-jump-go
     :desc "Back" :n "k" #'dumb-jump-back))
 (:map emmet-mode-keymap
   :i [C-return] #'emmet-expand-yas))

