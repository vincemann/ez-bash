import sys

def find_recent_dirs(dir_history_file,n,match_word=""):
    recent_dirs = []
    if dir_history_file:
        with open(dir_history_file, 'r') as file:
            while len(recent_dirs) < n :
                recent_dir = file.readline()
                if recent_dir == "":
                    eprint("reached end of dir-history file")
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
    try:
        index = int(input("supply index:"))
    except Exception as e:
        eprint("nothing selected | Exception")
        eprint(e)
        return None
    if index is None:
        eprint("nothing selected")
        return None
    try:
        return l[index]
    except IndexError as e:
        eprint("index out of range")
        return None


# GUI
def show_gui_selection(l, size=17):
    import tkinter as tk

    root = tk.Tk()
    global result_index

    listbox = tk.Listbox(root, font=('Times', size))
    listbox.config(width=0)
    listbox.pack()
    for item in l:
        eprint("inserting item: %s" % item)
        listbox.insert("end", item)
    listbox.select_set(0)
    listbox.focus_set()

    def exit_gui(event):
        global result_index
        try:
            result_index = listbox.curselection()[0]
            print("result_index: %d" % result_index)
            root.destroy()
        except Exception as e:
            eprint("nothing selected | Exception")
            eprint(e)
            result_index=None

    root.bind("<Return>", exit_gui)
    root.mainloop()
    if result_index is None:
        return None
    try:
        return l[result_index]
    except IndexError as e:
        eprint("index out of range")
        return None

def put_to_clipboard(text):
    import pyperclip
    pyperclip.copy(text)




def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

