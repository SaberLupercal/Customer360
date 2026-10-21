create or replace view customer_360_rfm as                        
with customer_statistic as 
(
    select  a."CustomerID" as customer,
            '2022-09-01'::date - max(a."Purchase_Date") as recency,
            round(count(a."Transaction_ID") / nullif(EXTRACT(YEAR FROM AGE(DATE '2022-09-01', b."created_date"::date)), 0)::numeric, 2) as frequency,
            round(sum(a."GMV") / nullif(EXTRACT(YEAR FROM AGE(DATE '2022-09-01', b."created_date"::date)), 0)::numeric, 2) as monetary            
    from
        customer_transaction a
        join customer_registered b on a."CustomerID" = b."ID"
    where
        a."Purchase_Date" is not null
        and a."GMV" <> 0
        and a."Purchase_Date" <= '2022-09-01'
    group by customer, b.created_date
),

customer_percent_rank as 
(
    select  *,
            -- Sử dụng PERCENT_RANK() đúng chuẩn, trả về giá trị từ 0 đến 1
            percent_rank() over(order by recency asc) as r_pct,
            percent_rank() over(order by frequency asc) as f_pct,
            percent_rank() over(order by monetary asc) as m_pct
    from customer_statistic
),

customer_rfm_score as 
(
    select  *,
            -- Recency: Càng lâu về trước (recency lớn) thì điểm R càng thấp (1), mới mua gần đây (recency nhỏ) điểm cao (4)
            case
              when r_pct > 0.75 then 1
              when r_pct > 0.50 then 2
              when r_pct > 0.25 then 3
              else 4
            end as "R",
            -- Frequency & Monetary: Giá trị càng cao thì điểm F, M càng cao (4)
            case
              when f_pct <= 0.25 then 1
              when f_pct <= 0.50 then 2
              when f_pct <= 0.75 then 3
              else 4
            end as "F",
            case
              when m_pct <= 0.25 then 1
              when m_pct <= 0.50 then 2
              when m_pct <= 0.75 then 3
              else 4
            end as "M"
    from customer_percent_rank
),

customer_rfm as
(
    select  *,
            CONCAT("R", "F", "M") as "RFM"
    from customer_rfm_score
)

select  customer,
        recency,
        frequency,
        monetary,
        "R",
        "F",
        "M",
        "RFM",
        case
            when "RFM" in ('111', '112', '113', '114', '121', '122', '123', '124', '131', '132', '133', '134', '141', '142', '143', '144') 
              then 'At-risk'
            when "RFM" in ('211', '212', '213', '214', '221', '222', '223', '224', '231', '232', '233', '234', '241', '242', '243', '244')     
              then 'Occasional'
            when "RFM" in ('311', '312', '313', '314', '321', '331', '341', '411', '412', '413', '414', '421', '431', '441')
              then 'Potential'
            when "RFM" in ('322', '323', '324', '332', '342', '422', '423', '424', '432', '442')
              then 'Loyal'
            else 'VIP'
        end as "Customers Segmentation"
from customer_rfm;
