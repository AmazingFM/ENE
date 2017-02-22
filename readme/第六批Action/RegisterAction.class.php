<?php
/**
 * 功能：用户注册
 * @author siht
 * 时间：2016-09-07
 */

class RegisterAction extends BaseAction
{
	//接口参数
	public $user_name;
	public $user_pass;
	public $remark_code;
	

	public function _initialize(){
		parent::_initialize();
		$this->checkSign();

		$this->user_name = I('user_name');
		$this->user_pass = I('user_pass');
		$this->remark_code = I('remark_code');

	}

	public function run() {
		
		$rs = $this->check();
		if($rs!==true){
			$this->returnError($rs['resp_desc'],'9002');
		}

		if($this->nick_name == '')
		{
			$this->nick_name='长生'.time();
		}

		//查询是否已注册
		$where = "user_name = '".$this->user_name."'";
		$user_query = M('Tuser')->where($where)->find();
		if(!empty($user_query))
		{
			$this->returnError('该用户已注册','2001');
		}

		$where = "remark_code = '".$this->remark_code."' and (user_type = 1 or user_type = 2)";
		$user_query = M('Tuser')->where($where)->find();
		if(empty($user_query))
		{
			$this->returnError('无效的推荐码','2002');
		}

		$user_info = array();
		$user_info['user_name'] = $this->user_name;
		$user_info['user_pass'] = $this->user_pass;
		$user_info['remark_code'] = $this->remark_code;
		$user_info['add_time'] = date('YmdHis');
		$user_info['nick_name'] = $this->nick_name;
		$user_info['full_code'] = $user_query['full_code'];

		$rs = M('Tuser')->add($user_info);
		if($rs === false)
		{
			$this->returnError('用户新增入库失败','9012');
		}

		$this->returnSuccess('注册成功！');	
		
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
		
		if($this->remark_code == '')
		{
			return array('remark_code'=>'推荐码不能为空！');
			return false;
		}
	
		return true;
	}
}
?>
