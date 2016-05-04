//
//  main.swift
//  sudoku_console
//
//  Created by 刘莎 on 16/3/23.
//  Copyright © 2016年 刘莎. All rights reserved.
//

import Foundation

//print("Hello, World!")
var sudoku_example:[Int]=[0,0,0,0,0,4,0,0,2,0,1,0,0,9,8,5,0,0,0,0,6,0,0,0,0,0,3,0,0,0,0,0,0,9,0,0,2,0,0,3,0,0,0,0,0,0,4,0,0,0,0,8,0,0,0,0,7,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,6]


class sudoku_table{
	var table=[Int]()
	let rownum=9
	let colnum=9
	var test: Int
	init(){
        test=0
		table=[Int](count:rownum*colnum,repeatedValue:0)
	}
    convenience init(newtable newtable_in:[Int]){
        self.init()
        for idx in 0 ... rownum*colnum-1 {
            table[idx]=newtable_in[idx]
        }
    }
	convenience init(newsudokutable newsudokutable_in:sudoku_table){
        self.init(newtable:newsudokutable_in.table)
	}
    
	func print_table(){
        print()
		for row in 0...rownum-1 {
			var tmp_row: String=""
			for col in 0...colnum-1{
				tmp_row+="\(table[row*colnum+col])|\t"
			}
			print("\(tmp_row)");
            print("__________________________________");
		}
        print()
	}
	subscript(row:Int,col:Int)->Int{
        get {
            return table[row*colnum+col]
        }
        set {
            table[row*colnum+col]=newValue
            
        }
	}
    func erase(){
        for idx in 0...rownum*colnum-1{
            table[idx]=0
        }
    }
    func rand_gen(){
        for idx in 0...rownum*colnum-1{
            table[idx]=Int(arc4random()%9+1)
        }
    }
    func check_solved()->Bool{
        for idx in 0...rownum*colnum-1{
            if table[idx]==0{
                return false
            }
        }
        return true
    }
    //func check_valid
}

class valid_node{
    var row_idx=0
    var col_idx=0
    var valid_set=[1,2,3,4,5,6,7,8,9]
    init (row:Int,col:Int){
        row_idx=row
        col_idx=col
    }
    var valid_num:Int{
        get{
            return valid_set.count
        }
    }
    func update_valid_set(valid_set_in:[Int]){
        valid_set=valid_set_in;
    }
    func check_valid(check_num:Int)->Bool{
        for number in valid_set{
            if number==check_num{
                return true
            }
        }
        return false
    }
    func remove_num(check_num:Int)->Bool{
        if !check_valid(check_num){
            return false
        }
        for idx in 0...valid_num-1{
            if check_num==valid_set[idx]{
                valid_set.removeAtIndex(idx)
                return true
            }
        }
        return false
    }
}

class sudoku_valid_set{
    var valid_matrix:[valid_node]=[]
    let rownum=9
    let colnum=9
    init (){
        for row in 0...rownum-1{
            for col in 0...colnum-1{
                valid_matrix.append(valid_node(row:row,col:col))
            }
        }
    }
    subscript(row:Int,col:Int)->valid_node{
        get{
            return valid_matrix[row*rownum+col]
        }
        set{
            valid_matrix[row*rownum+col].update_valid_set(newValue.valid_set)
        }
    }
    var valid_most:valid_node{
        get{
            var most=0
            var most_node:valid_node=valid_matrix[0]
            for node in valid_matrix{
                if node.valid_num > most{
                    most=node.valid_num
                    most_node=node
                }
            }
            return most_node
        }
    }
    var valid_least:valid_node{
        get{
            var least=9
            var least_node:valid_node=valid_matrix[0]
            for node in valid_matrix{
                if node.valid_num < least && node.valid_num>0{
                    least=node.valid_num
                    least_node=node
                }
            }
            return least_node
            
        }
        
    }
    func print_debug(){
        for row in 0...rownum-1{
            var tmp_row=""
            for col in 0...colnum-1{
                tmp_row+="\(self[row,col].valid_num)|\t"
            }
            print(tmp_row)
            print("__________________________________");
        }
        print("Most Node:\(self.valid_most.row_idx),\(self.valid_most.col_idx),\(self.valid_most.valid_num)")
        print("Least Node:\(self.valid_least.row_idx),\(self.valid_least.col_idx),\(self.valid_least.valid_num) valid set:\(self.valid_least.valid_set)")
    }
}

class sudoku{
    let rownum=9
    let colnum=9
    var table:sudoku_table
    var valid_info:sudoku_valid_set
    init(){
        table=sudoku_table()
        valid_info=sudoku_valid_set()
    }
    func check_num_cell(row_idx:Int,col_idx:Int,number:Int)->Bool{
        if number == 0 {
            return true
        }
        return valid_info[row_idx,col_idx].check_valid(number)
    }
    func set_number(row_idx:Int,col_idx:Int,number:Int){
        if number == 0{
            return
        }
        assert(table[row_idx,col_idx] == 0);
        assert(valid_info[row_idx,col_idx].check_valid(number))
        table[row_idx,col_idx]=number
        valid_info[row_idx,col_idx].valid_set=[Int]()
        //update col valid
        for cc in 0...colnum-1{
            valid_info[row_idx,cc].remove_num(number)
        }
        //update row valid
        for rr in 0...rownum-1{
            valid_info[rr,col_idx].remove_num(number)
        }
        //update cell valid
        let cell_row=Int(row_idx/3)
        let cell_col=Int(col_idx/3)
        for cell_row_idx in 0...2{
            for cell_col_idx in 0...2{
                valid_info[cell_row*3+cell_row_idx,cell_col*3+cell_col_idx].remove_num(number)
            }
        }
    }
    convenience init(table_in:[Int]){
        self.init()
        assert(table_in.count == rownum*colnum)
        for row in 0...rownum-1 {
            for col in 0...colnum-1 {
                let number=table_in[row*rownum+col]
                if check_num_cell(row,col_idx:col,number:number){
                    set_number(row,col_idx:col,number:number)
                }else{
                    print("init error @(\(row),\(col))")
                    return
                }
            }
        }
    }
    func search_row(row_idx:Int,col_idx:Int,number:Int)->Bool{
        for rr in 0...rownum-1{
            if rr == row_idx{
                continue
            }
            if check_num_cell(rr, col_idx: col_idx, number: number){
                return false
            }
        }
        return true
    }
    func search_col(row_idx:Int,col_idx:Int,number:Int)->Bool{
        for cc in 0...colnum-1 {
            if col_idx == cc {
                continue
            }
            if check_num_cell(row_idx, col_idx: cc, number: number) {
                return false
            }
        }
        return true
    }
    func search_cell(row_idx:Int,col_idx:Int,number:Int)->Bool{
        let cell_row=Int(row_idx/3)
        let cell_col=Int(col_idx/3)
        for cell_row_idx in 0...2{
            for cell_col_idx in 0...2{
                let tmp_row = cell_row*3+cell_row_idx
                let tmp_col = cell_col*3+cell_col_idx
                if tmp_row == row_idx && tmp_col == col_idx{
                    continue
                }
                if check_num_cell(tmp_row, col_idx: tmp_col, number: number) {
                    return false
                }
            }
        }
        return true
    }
    func simplify_m1()->Bool{
        var flag=false
        while(valid_info.valid_least.valid_num==1){
            let least_row=valid_info.valid_least.row_idx
            let least_col=valid_info.valid_least.col_idx
            let number=valid_info.valid_least.valid_set[0]
            set_number(least_row, col_idx: least_col, number: number)
            if table.check_solved() {
                return true
            }
            flag=true
        }
        return flag
    }
    func simplify_m2()->Bool{
        var flag=false
        for number in 1...9{
            for row_idx in 0...rownum-1{
                for col_idx in 0...colnum-1{
                    if table.check_solved() {
                        return true
                    }
                    if check_num_cell(row_idx, col_idx: col_idx, number: number){
                        var flag2=false
                        if search_row(row_idx, col_idx: col_idx, number: number) {
                            flag2=true
                        }
                        if search_col(row_idx, col_idx: col_idx, number: number) {
                            flag2=true
                        }
                        if search_cell(row_idx, col_idx: col_idx, number: number) {
                            flag2=true
                        }
                        if flag2 {
                            set_number(row_idx, col_idx: col_idx, number: number)
                            flag=true
                        }
                        

                        /*
                        if search_row(row_idx, col_idx: col_idx, number: number) || search_col(row_idx, col_idx: col_idx, number: number) || search_cell(row_idx, col_idx: col_idx, number: number) {
                            set_number(row_idx, col_idx: col_idx, number: number)
                            flag=true
                        }
                        */
                    }
                }
            }
        }
        return flag
    }
    func simplify(){
        var flag_m1=true
        var flag_m2=true
        while flag_m1 || flag_m2 {
            if table.check_solved() {
                return
            }
            flag_m1=simplify_m1()
            flag_m2=simplify_m2()
            table.print_table()
            valid_info.print_debug()
        }
        
    }
    func check_solved()->Bool{
        return table.check_solved()
    }
}

/*
let a=sudoku(table_in: sudoku_example)
a.table.print_table()
a.simplify()
a.table.print_table()
a.valid_info.print_debug()
*/



class sudoku_solver{
    var sudoku_stack=[sudoku]()
    var curr_sudoku=sudoku()
    var result_table=sudoku_table()
    let max_travel_depth=3
    var travel_depth=0
    func set_sudoku(table:[Int]){
        curr_sudoku=sudoku(table_in:table)
        result_table=sudoku_table(newtable: table)
        sudoku_stack=[sudoku]()
        let simplified_sudoku=sudoku(table_in:curr_sudoku.table.table)
        simplified_sudoku.simplify()
        sudoku_stack.append(simplified_sudoku)
        travel_depth=0
    }
    func solve_stack()->Bool{
        let tmp_sudoku=sudoku_stack[travel_depth]
        tmp_sudoku.simplify()
        if tmp_sudoku.table.check_solved() {
            result_table=tmp_sudoku.table
            return true
        }
        if travel_depth==max_travel_depth{
            travel_depth-=1
            sudoku_stack.removeLast()
            return false
        }
        let tmp_least=tmp_sudoku.valid_info.valid_least
        let least_row_idx=tmp_least.row_idx
        let least_col_idx=tmp_least.col_idx
        for number in tmp_least.valid_set{
            let sudoku_for_push=sudoku(table_in:tmp_sudoku.table.table)
            sudoku_for_push.set_number(least_row_idx,col_idx: least_col_idx,number: number)
            sudoku_stack.append(sudoku_for_push)
            travel_depth+=1
            if solve_stack() {
                return true
            }
        }
        travel_depth-=1
        sudoku_stack.removeLast()
        return false
    }
    func print_result(){
        result_table.print_table()
    }
}

/*
let a=sudoku_solver()
a.set_sudoku(sudoku_example)
a.print_result()
a.solve_stack()
a.print_result()
 */
/*
let a=sudoku_solver()
a.set_sudoku(sudoku_example)
a.print_result()
a.solve_stack()
a.print_result()
*/
/*
let a=sudoku_table(newtable:sudoku_example)
a.print_table()
a[2,2]=3
a.print_table()

var sudoku_table=[[Int]]();
for row in 1...9{
	var this_row=[Int]();
	for col in 1...9{
		let tmp=arc4random()%9+1;
		//print("\(tmp)\t",terminator:"");
		this_row.append(Int(tmp));
	}
    print("\(this_row)");
	sudoku_table.append(this_row);
}
*/

