ActiveAdmin.register User do
  menu label: "👥 사용자 관리"

  permit_params :email, :name, :phone, :role

  index do
    selectable_column
    id_column
    column "이름", :name
    column "이메일", :email
    column "전화번호", :phone
    column "역할", :role do |user|
      status_tag user.role, class: case user.role
                                  when 'jobseeker' then 'green'
                                  when 'hospital' then 'blue'
                                  when 'admin' then 'red'
                                  else 'gray'
                                  end
    end
    column "가입일", :created_at
    column "마지막 로그인", :last_sign_in_at
    actions
  end

  filter :name
  filter :email
  filter :role, as: :select, collection: User.roles
  filter :created_at

  form do |f|
    f.inputs "사용자 정보" do
      f.input :name, label: "이름"
      f.input :email, label: "이메일"
      f.input :phone, label: "전화번호"
      f.input :role, label: "역할", as: :select, collection: User.roles
    end
    f.actions
  end

  show do
    attributes_table do
      row "이름", :name
      row "이메일", :email
      row "전화번호", :phone
      row "역할" do |user|
        status_tag user.role
      end
      row "가입일", :created_at
      row "마지막 로그인", :last_sign_in_at
      row "로그인 횟수", :sign_in_count
    end

    if user.jobseeker? && user.profile
      panel "프로필 정보" do
        attributes_table_for user.profile do
          row "나이", :age
          row "경력", :experience_years
          row "희망 시급" do |profile|
            number_to_currency(profile.desired_hourly_rate, unit: "₩", precision: 0)
          end
          row "즉시 근무 가능", :available_immediately
          row "주소", :address
        end
      end

      panel "지원 내역" do
        table_for user.matchings.includes(:job => :hospital).order(created_at: :desc).limit(10) do
          column "구인공고" do |matching|
            link_to matching.job.title, admin_job_path(matching.job)
          end
          column "병원" do |matching|
            matching.job.hospital&.name
          end
          column "상태" do |matching|
            status_tag matching.status
          end
          column "지원일", :created_at
        end
      end
    end

    if user.hospital? && user.hospital
      panel "병원 정보" do
        attributes_table_for user.hospital do
          row "병원명", :name
          row "주소", :address
          row "전화번호", :phone
          row "설명", :description
        end
      end

      panel "구인공고" do
        table_for user.hospital.jobs.order(created_at: :desc).limit(10) do
          column "제목" do |job|
            link_to job.title, admin_job_path(job)
          end
          column "시급" do |job|
            number_to_currency(job.hourly_rate, unit: "₩", precision: 0)
          end
          column "근무일", :work_date
          column "상태" do |job|
            status_tag job.status
          end
          column "생성일", :created_at
        end
      end
    end
  end
end
