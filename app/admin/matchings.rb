ActiveAdmin.register Matching do
  menu label: "🤝 매칭 관리"

  permit_params :user_id, :job_id, :status, :notes

  index do
    selectable_column
    id_column
    column "구직자" do |matching|
      link_to matching.user.name, admin_user_path(matching.user)
    end
    column "구인공고" do |matching|
      link_to matching.job.title, admin_job_path(matching.job)
    end
    column "병원" do |matching|
      matching.job.hospital&.name
    end
    column "상태", :status do |matching|
      status_tag matching.status, class: case matching.status
                                        when 'applied' then 'orange'
                                        when 'accepted' then 'green'
                                        when 'rejected' then 'red'
                                        when 'completed' then 'blue'
                                        when 'cancelled' then 'gray'
                                        else 'default'
                                        end
    end
    column "지원일", :created_at
    column "업데이트", :updated_at
    actions
  end

  filter :user_name, as: :string
  filter :status, as: :select, collection: Matching.statuses
  filter :created_at

  form do |f|
    f.inputs "매칭 정보" do
      f.input :user, label: "구직자", collection: User.jobseeker.order(:name)
      f.input :job, label: "구인공고", collection: Job.active.includes(:hospital).order(:title)
      f.input :status, label: "상태", as: :select, collection: Matching.statuses
      f.input :notes, label: "메모", as: :text
    end
    f.actions
  end

  show do
    attributes_table do
      row "구직자" do |matching|
        link_to matching.user.name, admin_user_path(matching.user)
      end
      row "구인공고" do |matching|
        link_to matching.job.title, admin_job_path(matching.job)
      end
      row "병원" do |matching|
        matching.job.hospital&.name
      end
      row "상태" do |matching|
        status_tag matching.status
      end
      row "메모", :notes
      row "지원일", :created_at
      row "마지막 업데이트", :updated_at
    end

    panel "구직자 프로필" do
      attributes_table_for matching.user.profile do
        row "나이", :age
        row "경력", :experience_years
        row "희망 시급" do |profile|
          number_to_currency(profile.desired_hourly_rate, unit: "₩", precision: 0) if profile.desired_hourly_rate
        end
        row "즉시 근무 가능", :available_immediately
        row "전문 분야", :specialties
      end
    end

    panel "구인공고 정보" do
      attributes_table_for matching.job do
        row "제목", :title
        row "설명", :description
        row "시급" do |job|
          number_to_currency(job.hourly_rate, unit: "₩", precision: 0)
        end
        row "근무일", :work_date
        row "근무 시간" do |job|
          "#{job.start_time&.strftime('%H:%M')} - #{job.end_time&.strftime('%H:%M')}"
        end
      end
    end
  end

  # 매칭 상태 변경 액션
  batch_action "승인", confirm: "선택한 매칭을 승인하시겠습니까?" do |ids|
    batch_action_collection.find(ids).each do |matching|
      matching.update!(status: :accepted)
      # 알림 생성
      Notification.create_for_job_acceptance(matching.user, matching.job)
    end
    redirect_to collection_path, notice: "#{ids.count}개의 매칭이 승인되었습니다."
  end

  batch_action "거절", confirm: "선택한 매칭을 거절하시겠습니까?" do |ids|
    batch_action_collection.find(ids).each do |matching|
      matching.update!(status: :rejected)
    end
    redirect_to collection_path, notice: "#{ids.count}개의 매칭이 거절되었습니다."
  end
end
