<?php
/**
 * 功能：分类查询
 * @author siht
 * 时间：2015-09-21
 */

class SpecQueryAction extends BaseAction
{
	//接口参数
	public $level;	//分类级别
	public $parent_code;//上级编号

	public function _initialize(){
		parent::_initialize();
		$this->checkSign();
	
		$this->level = I('level'); 
		$this->parent_code = I('parent_code');

	}

	public function run() {
		
		$rs = $this->check();
		if($rs!==true){
			$this->returnError($rs['resp_desc'],'9002');
		}
		
		$where = "1 > 0";
		if(isset($this->level) && $this->level !=''){
			$where = " and level = ".$this->level;; 
		}

		if(isset($this->parent_code) && $this->parent_code !=''){
			$where .= " and parent_code = '".$this->parent_code."'"; 
		}
		
		$spec_list = M('Tspec')->field('id,name,code,parent_code,icon,level,full_code')->order('full_code asc')->where($where)->select();
		
		$this->returnSuccess("查询成功",array("total_count"=>count($spec_list),"spec_list"=>$spec_list));
	}

	

	private function check(){
		
		return true;
	}
}
?>
