<?php
/**
 * 功能 订单修改
 * @author siht
 * 时间：2016-10-03
 */
class OrderModifyAction extends BaseAction 
{
	public $user_id;		//用户id
	public $order_id;		//订单id
	public $status;			//订单状态 7-取消订单 1- 订单支付确认


	public function _initialize(){
		parent::_initialize();
		$this->checkSign();

		$this->user_id = I('user_id');
		$this->order_id = I('order_id'); 
		$this->status = I('status'); 

	}

	public function run() {		
		$rs = $this->check(); 
		if(!($rs===true)){
			$this->returnError($rs['resp_desc'],'9002');
		}
		$todayTime = date('YmdHis');

		$where = "order_id = ".$this->order_id;

		$order = M('Torder')->where($where)->find();	
		if(!empty($order)){
			if($this->user_id != $order['user_id'])
			{
				$this->returnError("不可操作非自己的订单", '7002');
			}
			if($order['status'] != 0)
			{
				$this->returnError("只能操作待支付的订单", '7002');
			}

			//起事务
			M()->startTrans();
			if($this->status == 1)//支付确认
			{
				//查用户信息
				$where_case = "id = ".$this->user_id;
				$user_info = M('Tuser')->where($where_case)->find();
				if(empty($user_info))
				{
					M()->rollback();
					$this->returnError("用户不存在", '7006');
				}

				$user_info['occur_amt'] = $order['amt'];

				//查推荐人
				$where_case = "remark_code = ".$user_info['remark_code']." and user_type > 0";
				$recommen_one = M('Tuser')->where($where_case)->find();
				if(empty($recommen_one))
				{
					M()->rollback();
					$this->returnError("没找到推荐人", '7007');
				}

				//查利润率
				$where_case = "code = '0000'";
				$rate_one =  M('TsysParam')->where($where_case)->find();
				$recommen_one['occur_amt'] = $order['amt']*$rate_one;
				if(empty($rate_one))
				{
					M()->rollback();
					$this->returnError("代理人客户利润率未设置", '7008');
				}

				/*if($recommen_one['user_type'] == '1')//省级代理人
				{
					//$recommen_one['occur_amt'] = $order['amt']*$rate_one;
				}*/
				if($recommen_one['user_type'] == '2')//市级代理人
				{
					//推荐人下级利润率
					$where_case = "code = '0001'";
					$rate_two =  M('TsysParam')->where($where_case)->find();
					if(empty($rate_two))
					{
						M()->rollback();
						$this->returnError("代理人客户利润率未设置", '7009');
					}

					//查询上级代理人
					$where_case = "remark_code = ".$recommen_one['remark_code']." and user_type > 0";
					$recommen_two = M('Tuser')->where($where_case)->find();
					if(empty($recommen_two))
					{
						M()->rollback();
						$this->returnError("没找到上级推荐人", '7010');
					}
					$recommen_two['occur_amt'] = $recommen_one['occur_amt']*$recommen_two;
					$recommen_one['occur_amt'] = $recommen_one['occur_amt'] - $recommen_two['occur_amt'];

					$rs = $this->update_stat($recommen_two); 
					if(!($rs===true)){
						$this->returnError('更新推荐人2统计信息失败','7032');
					}
				}
				

				$rs = $this->update_stat($recommen_one); 
				if(!($rs===true)){
					$this->returnError('更新推荐人1统计信息失败','7032');
				}

				$rs = $this->update_stat($user_info); 
				if(!($rs===true)){
					$this->returnError('更新用户统计信息失败','7032');
				}

			}
			else if($this->status == 7)
			{
				//查询订单明细
				$where_case = "order_id = ".$this->order_id;
				$order_detail = M('TorderDetail')->where($where_case)->select();
				if(!empty($order_detail)){
					//回滚已售数，释放库存
					foreach($order_detail as $good_info)
					{
						$where_case = "goods_id = '".$good_info['goods_id']."' and sub_gid = '".$good_info['sub_gid']."'";
						$rs = M('Tgoods')->where($where_case)->setDec('sale_count',$good_info['qty']);
						if(!$rs)
						{
							M()->rollback();
							$this->returnError("更新商品[".$goods_info['goods_name']."-".$goods_info['sub_gname']."]已售数失败！", '2018');
						}
					}
				}
				else
				{
					M()->rollback();
					$this->returnError("未找到订单明细", '7005');
				}
			}
			else
			{
				M()->rollback();
				$this->returnError("订单不能变更为该状态", '7077');
			}
			

			//更新订单明细状态
			$detail_new = array();
			$detail_new['status'] = $this->status;
			$rs = M('TorderDetail')->where($where)->save($detail_new);
			if($rs === false)
			{
				M()->rollback();
				$this->returnError("订单明细更新失败", '7004');
			}

			//更新订单状态
			$order_new = array();
			$order_new['status'] = $this->status;
			$rs = M('Torder')->where($where)->save($order_new);
			if($rs === false)
			{
				M()->rollback();
				$this->returnError("订单更新失败", '7003');
			}

			M()->commit(); 
			$this->returnSuccess("操作成功");

		}
		else
		{
			$this->returnError("无此订单", '7001');
		}
	}
	
	private function check(){	
		if($this->user_id == '')
		{
			return array('resp_desc'=>'用户id不能为空！');
			return false;
		}
		if($this->order_id == '')
		{
			return array('resp_desc'=>'订单号不能为空！');
			return false;
		}
		
		return true;
	}	

	//更新统计信息
	private function update_stat($user){
		$date = date('Ymd');
		$day_stat = array();
		$day_stat['user_id'] = $user['$user'];
		$day_stat['date'] = $date;
		$day_stat['occur_amt'] = $user['occur_amt'];

		$where_info = " user_id = ".$user['$user']." and date = ".$date;
		$occur_count = M('TuserDayStat')->where($where_info)->getField('occur_count');
		if(!$occur_count)//新增
		{
			$day_stat['occur_count'] = 1;
			$rs = M('TuserDayStat')->add($day_stat);
			if(!rs)
			{
				return false;
			}
		}
		else//更新
		{
			$day_stat['occur_count'] = $occur_count + 1;
			$rs = M('TuserDayStat')->where($where_info)->save($day_stat);
			if(!rs)
			{
				return false;
			}
		}

		return true;
	}	
}
?>