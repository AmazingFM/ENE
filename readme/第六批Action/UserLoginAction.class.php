<?php
/**
 * 功能：用户登陆
 * @author siht
 * 时间：2016-09-07
 */

class UserLoginAction extends BaseAction
{
	//接口参数
	public $user_name;
	public $user_pass;
	public $pass_type;
	

	public function _initialize(){
		parent::_initialize();
		$this->checkSign();
	
		$this->user_name = I('user_name');
		$this->user_pass = I('user_pass');
	}

	public function run() {
		
		$rs = $this->check();
		if($rs!==true){
			$this->returnError($rs['resp_desc'],'9002');
		}
		
		//1.取用户基本信息
		$where = "user_name = '".$this->user_name."'";	
		$field = array('id','id','user_type','sexual','user_icon','nick_name','user_pass','user_status','remark_code');
		$user_info = M('Tuser')->where($where)->field($field)->find();
		if(empty($user_info))
		{
			$this->returnError('用户不存在','9011');
		}

		if($user_info['user_pass'] != $this->user_pass)
		{
			$this->returnError('登陆密码错误','9012');
		}
		
		if($user_info['user_status'] == '0')
		{
			$this->returnError('用户审核中，请等待','9012');
		}

		//2.更新登陆信息
		$where =  "id =". $user_info['id'];
		$login_info = array();
		$login_info['last_login_time'] = date('YmdHis');
		$login_info['token'] = md5($this->user_name.$login_info['last_login_time']);
		$rs = M('Tuser')->where($where)->save($login_info);
		if(!$rs)
		{
			$this->returnError('更新登陆信息失败','9017');
		}
		$user_info['token'] = $login_info['token'];
		

		//3.擦除用户密码、用户状态，不返回
		unset($user_info['user_pass']);
		unset($user_info['user_status']);
		
		$this->returnSuccess("登陆成功",$user_info);
	}

	

	private function check(){
		if($this->user_name == '')
		{
			return array('resp_desc'=>'用户名不能为空！');
			return false;
		}
		if($this->user_pass == '')
		{
			return array('resp_desc'=>'用户密码不能为空！');
			return false;
		}
		
		return true;
	}
}
?>
