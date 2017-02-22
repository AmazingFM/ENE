<?php
/**
 * 功能：用户密码重置找回
 * @author siht
 * 时间：2015-09-22
 */

class UserPassResetAction extends BaseAction
{
	//接口参数
	public $user_name;
	public $new_pass;

	public function _initialize(){
		parent::_initialize();
		$this->checkSign();
	
		$this->user_name = I('user_name');
		$this->new_pass = I('new_pass');
	}

	public function run() {
		$rs = $this->check();
		if($rs!==true){
			$this->returnError($rs['resp_desc'],'9002');
		}
		
		$where = "user_name = ".$this->user_name;
		$user_info = M('Tuser')->where($where)->find();

		if(empty($user_info))
		{
			$this->returnError('用户名不存在','9011');
		}

		$new_user = array();
		$new_user['user_pass'] = $this->new_pass;
		
		
		$rs = M('Tuser')->where($where)->save($new_user);
		if($rs === false)
		{
			$this->returnError('重置密码失败','9012');
		}
		
		$this->returnSuccess("重置密码成功",array("user_id"=>$this->user_id));
	}

	

	private function check(){
		if($this->user_name == '')
		{
			return array('resp_desc'=>'用户名[user_name]不能为空！');
			return false;
		}
		if($this->new_pass == '')
		{
			return array('resp_desc'=>'重置密码不能为空！');
			return false;
		}

		return true;
	}
}
?>