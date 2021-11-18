import sys

def find_recent_dirs(n,match_word=""):
    recent_dirs = []
    if dir_history_file:
        with open(dir_history_file, 'r') as file:
            while len(recent_dirs) < n :
                recent_dir = file.readline()
                if recent_dir == "":
                    break
                if match_word != "":
                    if match_word.lower() in recent_dir.lower():
                        recent_dirs.append(recent_dir.rstrip())
                else:
                    recent_dirs.append(recent_dir.rstrip())
            file.close()
    return recent_dirs

def show_terminal_selection(l):
    index = 0
    for e in l:
        print(str(index)+": %s" % e)
    index = input("supply index:")
    return l[index]


# GUI
def show_gui_selection(l, size=17):
    import tkinter as tk

    root = tk.Tk()
    global result_index

    listbox = tk.Listbox(root, font=('Times', size))
    listbox.config(width=0)
    listbox.pack()
    for item in l:
        listbox.insert("end", item)
    listbox.select_set(0)
    listbox.focus_set()

    def exit_gui(event):
        global result_index
        result_index = listbox.curselection()[0]
        print("result_index: %d" % result_index)
        root.destroy()

    root.bind("<Return>", exit_gui)
    root.mainloop()

    return l[result_index]

def put_to_clipboard(text):
    import pyperclip
    pyperclip.copy(text)




def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)
