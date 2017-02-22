<?php
/**
 * 功能：用户查询
 * @author siht
 * 时间：2016-09-20
 */

class UserQueryAction extends BaseAction
{
	//接口参数
	public $user_id;  //用户id
	public $qry_usr_id;//查询的用户id
	
	

	public function _initialize(){
		parent::_initialize();
		$this->checkSign();

		$this->user_id = I('user_id');
		$this->qry_usr_id = I('qry_usr_id');
				
	}

	public function run() {
		
		$rs = $this->check();
		if($rs!==true){
			$this->returnError($rs['resp_desc'],'9002');
		}
		
		//1.查用户基本信息
		$where = "id = ".$this->qry_usr_id;
		$field = array('id','true_name','contact_eml','true_name','sexual','birthday','user_icon','nick_name','remark_code');
	
		$user_info = M('Tuser')->field($field)->where($where)->find();
		if(empty($user_info))
		{
			$this->returnError('用户不存在','9011');
		}
	
		$this->returnSuccess("查询用户信息成功",$user_info);
	}

	

	private function check(){
		if($this->user_id == '')
		{
			return array('resp_desc'=>'用户id不能为空！');
			return false;
		}
		if($this->qry_usr_id == '')
		{
			return array('resp_desc'=>'所查询的用户id不能为空！');
			return false;
		}
	
		return true;
	}
}
?>