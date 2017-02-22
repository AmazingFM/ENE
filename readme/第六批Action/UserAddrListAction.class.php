<?php
/**
 * 功能 收货地址列表查询
 * @author siht
 * 时间：2016-09-10
 */
class UserAddrListAction extends BaseAction 
{
	public $user_id;		//用户id
	public $status;		//状态

	public function _initialize(){
		parent::_initialize();
		$this->checkSign();

		$this->user_id = I('user_id'); //用户id
		$this->status = I('status'); //用户id
	}
		
	public function run() {		
		$rs = $this->check(); 
		if(!($rs===true)){
			$this->returnError($rs['resp_desc'],'9002');
		}

		$where = "user_id = ".$this->user_id;	
		
		if(isset($this->status) && $this->status !=''){	
			$where .= " and status = ".$this->status;
		}
		else
		{
			$where .= " and status < 2";
		}
		$usraddr_list = M('TuserAddr')->where($where)->select();
		
		if(!empty($usraddr_list)){					
			$this->returnSuccess($resp_desc, array('usraddr_list' => $usraddr_list));
		}
		else
		{
			$this->returnError("无收货地址", '0000');
		}
	}
	
	private function check(){		
		if($this->user_id == '')
		{
			return array('resp_desc'=>'用户id不能为空！');
			return false;
		}
		
		return true;
	}	
}
?>