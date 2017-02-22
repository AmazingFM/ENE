<?php
/**
 * 功能：用户收货地址新增
 * @author siht
 * 时间：2016-09-10
 */

class UserAddrAddAction extends BaseAction
{
	//接口参数
	public $user_id;  //用户id
	public $delivery_name;// 收货人
	public $contact_no;//联系电话
	public $province_code;//省编号
	public $province;//省
	public $city_code;//市编号
	public $city;//市
	public $town_code;//区编号
	public $town;//区
	public $delivery_addr;//收货地址
	public $status;//用户状态：0-默认地址 1-正常 ，不传为1 如首次新增可传0 同时设置为默认地址


	
	

	public function _initialize(){
		parent::_initialize();
		$this->checkSign();
		
		$this->user_id = I('user_id');
		$this->delivery_name = I('delivery_name');
		$this->contact_no = I('contact_no');
		$this->province_code = I('province_code');
		$this->province = I('province');
		$this->city_code = I('city_code');
		$this->city = I('city');
		$this->town_code = I('town_code');
		$this->town = I('town');
		$this->delivery_addr = I('delivery_addr');
		$this->status = I('status',1);
					
	}

	public function run() {
		
		$rs = $this->check();
		if($rs!==true){
			$this->returnError($rs['resp_desc'],'9002');
		}
		

		//如设置为默认收货地址 则先将该用户的原默认收货地址状态更新为正常
		if($this->status == 0)
		{
			$upt_where = "user_id = ".$this->user_id." and status = 0";
			$rs = M('TuserAddr')->where($upt_where)->save(array('status'=>1));
			
		}

		$user_addr = array();
		$user_addr['user_id'] = $this->user_id;
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

		$rs = M('TuserAddr')->add($user_addr);
		if($rs === false)
		{
			$this->returnError('收货地址新增入库失败','9012');
		}

		$id = mysql_insert_id();

		$this->returnSuccess('收货地址新增成功！',array('id'=>$id));	
	}

	

	private function check(){
		if($this->user_id == '')
		{
			return array('resp_desc'=>'用户id不能为空！');
			return false;
		}
		if($this->delivery_name == '')
		{
			return array('resp_desc'=>'收货人不能为空！');
			return false;
		}
		if($this->contact_no == '')
		{
			return array('resp_desc'=>'联系电话不能为空！');
			return false;
		}
		if($this->delivery_addr == '')
		{
			return array('resp_desc'=>'收货地址');
			return false;
		}
	
		return true;
	}
}
?>
