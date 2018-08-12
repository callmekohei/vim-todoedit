# vim-todoedit

vim-todoedit edits todo.txt with vim-partedit. It's useful to manage your tasks by folding with +folder, ++subfolder, due-date and @contexts.

## Images

create `todo.txt` file

![alt text](./pic/foo01.png)

write some tasks

![alt text](./pic/foo02.png)

sort and fold by due date

```
<Space> s d
```

![alt text](./pic/foo03.png)


press `<Space> <Space>` on `+- 006 due:2018-09-01 ············` line.

open another buffer

```
<Space> <Space>
```

![alt text](./pic/foo04.png)

sort and fold by @Contexts

You can get just tasks what you want.

```
<Space> s c
```

![alt text](./pic/foo05.png)


So you make a task done.


```
<Space> x
```

![alt text](./pic/foo06.png)


## Complition

needs :  
[deoplete.nvim](https://github.com/Shougo/deoplete.nvim)  
[deoplete-todoedit](https://github.com/callmekohei/deoplete-todoedit)  

![alt text](./pic/completion.png)

## repeated tasks

Before done

![alt text](./pic/beforRec.png)

After done

![alt text](./pic/afterRec.png)

## Thanks

    @thinca       vim-partedit
    @freitass     todo.txt-vim
    @dbeniamine   todo.txt-vim

## Requires

[vim-partedit](https://github.com/thinca/vim-partedit)

## Keymaps

sort and fold

| press key       | functions      |
| :-------------  | :------------- |
| \<localleader\>s  | previous sort  |
| \<localleader\>sf | +Folder        |
| \<localleader\>ss | ++SubFolder    |
| \<localleader\>sc | @Contexts      |
| \<localleader\>sd | due date       |
| \<localleader\>sx | completed task |

done and swipe

| press key       | functions           |
| :-------------  | :-------------      |
| \<localleader\>x  | toggle done tasks   |
| \<localleader\>X  | Swipe tasks         |

## More info

see: [doc/todoedit.txt](https://github.com/callmekohei/vim-todoedit/blob/master/doc/todoedit.txt)
