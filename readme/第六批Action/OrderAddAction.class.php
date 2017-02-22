<?php
/**
 * 功能：订单新增
 * @author siht
 * 时间：2016-09-10
 */

class OrderAddAction extends BaseAction
{
	//接口参数
	public $user_id;  //用户id
	public $amt;	//支付金额
	public $delivery_name;// 收货人
	public $contact_no;//联系电话
	public $province_code;//省编号
	public $province;//省
	public $city_code;//市编号
	public $city;//市
	public $town_code;//区编号
	public $town;//区
	public $delivery_addr;//收货地址
	public $order_detail_arr;//订单明细列表;存jason数组，需要传goods_id，sub_gid，price，qty，amt
	public $order_detail_ex;

	
	

	public function _initialize(){
		parent::_initialize();
		$this->checkSign();
		
		$this->user_id = I('user_id');
		$this->amt = I('amt');
		$this->delivery_name = I('delivery_name');
		$this->contact_no = I('contact_no');
		$this->province_code = I('province_code');
		$this->province = I('province');
		$this->city_code = I('city_code');
		$this->city = I('city');
		$this->town_code = I('town_code');
		$this->town = I('town');
		$this->delivery_addr = I('delivery_addr');
		$this->order_detail_arr = I('order_detail_arr');
					
	}

	public function run() {
		
		$rs = $this->check();
		if($rs!==true){
			$this->returnError($rs['resp_desc'],'9002');
		}

		$now = date('YmdHis');
		$order_id = $now.$user_id.mt_rand(1000,9999);

		//起事务
		M()->startTrans();
		//$detail_arr = html_entity_decode($this->order_detail_arr);
		$detail_arr = htmlspecialchars_decode($this->order_detail_arr);
		$goods_array = json_decode($detail_arr,true);

		//1.处理订单明细
		foreach($goods_array as $order_detail)
		{
			//1.1 校验商品信息及库存
			$where =  "goods_id = '".$order_detail['goods_id']."' and sub_gid = '".$order_detail['sub_gid']."'";
			$fields = array('goods_id', 'sub_gid', 'goods_name', 'sub_gname','store_count','sale_count','status');
			$goods_info = M('Tgoods')->field($fields)->where($where)->find();
			
			if(empty($goods_info))
			{
				M()->rollback();
				$this->returnError("找不到子商品[".$order_detail['goods_id']."-".$order_detail['sub_gid']."]的详情", '1004');
			}
			
			if(($goods_info['store_count'] - $goods_info['sale_count']) < $order_detail['qty'])
			{
				M()->rollback();
				$this->returnError("该商品[".$goods_info['goods_name']."-".$goods_info['sub_gname']."]库存不足", '1004');
			}

			//1.2 增加已售数（拍下即扣，若支付超时再回滚）
			$rs = M('Tgoods')->where($where)->setInc('sale_count',$order_detail['qty']);
			if(!$rs)
			{
				M()->rollback();
				$this->returnError("更新商品[".$goods_info['goods_name']."-".$goods_info['sub_gname']."]已售数失败！", '2018');
			}

			//1.3 子订单入库
			$order_detail['order_id'] = $order_id;
			$order_detail['goods_name'] = $goods_info['goods_name'];
			$order_detail['sub_gname'] = $goods_info['sub_gname'];
			$order_detail['amt'] = $order_detail['qty'] * $order_detail['price'];

			$rs = M('TorderDetail')->add($order_detail);
			if($rs === false)
			{
				M()->rollback();
				$this->returnError("商品[".$goods_Info['goods_name']."-".$goods_Info['sub_gname']."]入库失败",'9012');
			}
		}

		
		//2.订单信息入库
		$order = array();
		$order['order_id'] = $order_id;
		$order['user_id'] = $this->user_id;
		$order['amt'] = $this->amt;
		$order['add_time'] = $now;
		$order['delivery_name'] = $this->delivery_name;
		$order['contact_no'] = $this->contact_no;
		$order['province_code'] = $this->province_code;
		$order['province'] = $this->province;
		$order['city_code'] = $this->city_code;
		$order['city'] = $this->city;
		$order['town_code'] = $this->town_code;
		$order['town'] = $this->town;
		$order['delivery_addr'] = $this->delivery_addr;
	
		$rs = M('Torder')->add($order);
		if($rs === false)
		{
			M()->rollback();
			$this->returnError('订单新增入库失败','9012');
		}

		M()->commit(); 
		$this->returnSuccess('订单生成成功！',array('order_id'=>$order_id));	
	}

	

	private function check(){
		if($this->user_id == '')
		{
			return array('resp_desc'=>'用户id不能为空！');
			return false;
		}
		if($this->amt == '')
		{
			return array('resp_desc'=>'订单金额不能为空！');
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
			return array('resp_desc'=>'收货地址不能为空');
			return false;
		}
		if($this->order_detail_arr == '')
		{
			return array('resp_desc'=>'商品列表不能为空');
			return false;
		}
	
		return true;
	}
}
?>
