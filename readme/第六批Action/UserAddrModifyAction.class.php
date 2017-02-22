<?php
/**
 * 功能：用户收货地址修改
 * @author siht
 * 时间：2016-09-10
 */

class UserAddrModifyAction extends BaseAction
{
	//接口参数
	public $user_id;  //用户id
	public $usraddr_id;		  //修改信息id
	public $delivery_name;// 收货人
	public $contact_no;//联系电话
	public $province_code;//省编号
	public $province;//省
	public $city_code;//市编号
	public $city;//市
	public $town_code;//区编号
	public $town;//区
	public $delivery_addr;//收货地址
	public $status;//用户状态：0-默认地址 1-正常 ，传0 为设置当前收货地址为默认收货地址 传2-删除收货地址


	
	

	public function _initialize(){
		parent::_initialize();
		$this->checkSign();
		
		$this->user_id = I('user_id');
		$this->usraddr_id = I('usraddr_id');
		$this->delivery_name = I('delivery_name');
		$this->contact_no = I('contact_no');
		$this->province_code = I('province_code');
		$this->province = I('province');
		$this->city_code = I('city_code');
		$this->city = I('city');
		$this->town_code = I('town_code');
		$this->town = I('town');
		$this->delivery_addr = I('delivery_addr');
		$this->status = I('status');
					
	}

	public function run() {
		
		$rs = $this->check();
		if($rs!==true){
			$this->returnError($rs['resp_desc'],'9002');
		}
		
		//校验要修改的信息
		$where = "id = ".$this->usraddr_id;
		$field = array('user_id', 'status');

		$usr_addr = M('TuserAddr')->field($field)->where($where)->find();
		if(empty($usr_addr))
		{
			$this->returnError("待修改的收货地址不存在", '1004');
		}
		if($usr_addr['user_id'] != $this->user_id)
		{
			$this->returnError("不能修改的不属于自己的收货信息", '1005');
		}
		if($usr_addr['status'] = '2')
		{
			$this->returnError("收货地址已删除", '1006');
		}


		//如设置为默认收货地址 则先将该用户的原默认收货地址状态更新为正常
		if($this->status == 0)
		{
			$upt_where = "user_id = ".$this->user_id." and status = 0";
			$rs = M('TuserAddr')->where($upt_where)->save(array('status'=>1));
			
		}
		
		$user_addr = array();
		$user_addr['delivery_name'] = $this->delivery_name;
		$user_addr['contact_no'] = $this->contact_no;
		$user_addr['province_code'] = $this->province_code;
		$user_addr['province'] = $this->province;
		$user_addr['city_code'] = $this->city_code;
		$user_addr['city'] = $this->city;
		$user_addr['town_code'] = $this->town_code;
		$user_addr['town'] = $this->town;
		$user_addr['delivery_addr'] = $this->delivery_addr;
		$user_addr['status'] = $this->status;

		$rs = M('TuserAddr')->where($where)->save($user_addr);
		if($rs === false)
		{
			$this->returnError('收货地址更新失败','9012');
		}

		$this->returnSuccess('收货地址更新成功！');	
	}

	

	private function check(){
		if($this->user_id == '')
		{
			return array('resp_desc'=>'用户id不能为空！');
			return false;
		}
		if($this->usraddr_id == '')
		{
			return array('resp_desc'=>'id不能为空！');
			return false;
		}
		
	
		return true;
	}
}
?>
