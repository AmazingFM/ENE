<?php
/**
 * 功能：用户修改
 * @author siht
 * 时间：2015-09-07
 */

class UserModifyAction extends BaseAction
{
	//接口参数
	public $user_id;
	public $user_pass;
	public $new_pass;
	public $true_name;
	public $sexual;
	public $birthday;
	public $contact_eml;
	public $user_icon;
	public $nick_name;//昵称

	public function _initialize(){
		parent::_initialize();
		$this->checkSign();
	
		$this->user_id = I('user_id');
		$this->user_pass = I('user_pass');
		$this->new_pass = I('new_pass');
		$this->true_name = I('true_name');
		$this->sexual = I('sexual');
		$this->birthday = I('birthday');
		$this->contact_eml = I('contact_eml');
		$this->user_icon = I('user_icon');
		$this->nick_name = I('nick_name');
		
	}

	public function run() {
		
		$rs = $this->check();
		if($rs!==true){
			$this->returnError($rs['resp_desc'],'9002');
		}
		
		$where = "id = ".$this->user_id;

		$user_info = M('Tuser')->where($where)->find();

		if(empty($user_info))
		{
			$this->returnError('用户不存在','9011');
		}

		$new_user = array();
		if($this->new_pass != '')
		{
			if(trim($this->user_pass) != trim($user_info['user_pass']))
			{
				$this->returnError('原密码不正确','9013');
			}
			$new_user['user_pass'] = $this->new_pass;
		}
		if($this->sexual != '')
		{
			$new_user['sexual'] = $this->sexual;
		}
		if($this->birthday != '')
		{
			$new_user['birthday'] = $this->birthday;
		}
		if($this->contact_eml != '')
		{
			$new_user['contact_eml'] = $this->contact_eml;
		}
		if($this->user_icon != '')
		{
			$new_user['user_icon'] = $this->user_icon;
		}
		if($this->nick_name != '')
		{
			$new_user['nick_name'] = $this->nick_name;
		}
		if($this->true_name != '')
		{
			$new_user['true_name'] = $this->true_name;
		}
		

		$rs = M('Tuser')->where($where)->save($new_user);
		if($rs === false)
		{
			$this->returnError('修改失败','9012');
		}
		
		$this->returnSuccess("修改成功",array("user_id"=>$this->user_id));
	}

	

	private function check(){
		if($this->user_id == '')
		{
			return array('resp_desc'=>'用户名[user_id]不能为空！');
			return false;
		}

		if($this->new_pass != '')
		{
			if($this->user_pass == '')
			{
				return array('resp_desc'=>'原密码[user_pass]不能为空！');
				return false;
			}
		}
		return true;
	}
}
?>