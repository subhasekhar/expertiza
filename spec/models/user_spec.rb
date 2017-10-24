describe User do
  let(:user) do
    User.new name: 'abc', fullname: 'abc xyz', email: 'abcxyz@gmail.com', password: '12345678', password_confirmation: '12345678',
             email_on_submission: 1, email_on_review: 1, email_on_review_of_review: 0, copy_of_emails: 1, handle: 'handle'
  end
  let(:user1) { User.new name: 'abc', fullname: 'abc bbc', email: 'abcbbc@gmail.com', password: '123456789', password_confirmation: '123456789' }
  let(:user2) { User.new name: 'abc', fullname: 'abc bbc', email: 'abcbbe@gmail.com', password: '123456789', password_confirmation: '123456789' }

  describe '#name' do
    it 'returns the name of the user' do
      expect(user.name).to eq('abc')
    end
    it 'Validate presence of name which cannot be blank' do
      expect(user).to be_valid
      user.name = '  '
      expect(user).not_to be_valid
    end
    it 'Validate that name is always unique' do
      expect(user1).to validate_uniqueness_of(:name)
    end
  end

  describe '#fullname' do
    it 'returns the full name of the user' do
      expect(user.fullname).to eq('abc xyz')
    end
  end

  describe '#email' do
    it 'returns the email of the user' do
      expect(user.email).to eq('abcxyz@gmail.com')
    end

    it 'Validate presence of email which cannot be blank' do
      user.email = '  '
      expect(user).not_to be_valid
    end

    it 'Validate the email format' do
      user.email = 'a@x'
      expect(user).not_to be_valid
    end

    it 'Validate the email format' do
      user.email = 'ax.com'
      expect(user).not_to be_valid
    end

    it 'Validate the email format' do
      user.email = 'axc'
      expect(user).not_to be_valid
    end

    it 'Validate the email format' do
      user.email = '123'
      expect(user).not_to be_valid
    end

    it 'Validate the email format correctness' do
      user.email = 'a@x.com'
      expect(user).to be_valid
    end
  end

  describe '#salt_first?' do
    it 'will always return true' do
      expect(user.salt_first?).to be true
    end
  end

  describe '#get_available_users' do
    it 'returns the first 10 visible users'
  end

  describe '#can_impersonate?' do
    it 'can impersonate target user if current user is super admin' do
      allow(user1).to receive_message_chain("role.super_admin?"){true}
      expect(user1.can_impersonate?(user)).to be true
    end
    it 'can impersonate target user if current user is the TA of target user'do
      allow(user1).to receive_message_chain("role.super_admin?"){false}
      allow(user1).to receive(:is_teaching_assistant_for?).and_return(user)
      expect(user1.can_impersonate?(user)).to be true

    end
    it 'can impersonate target user if current user is the recursively parent of target user'do
      allow(user1).to receive_message_chain("role.super_admin?"){true}
      allow(user1).to receive(:is_recursively_parent_of).and_return(user)
      expect(user1.can_impersonate?(user)).to be true
    end
    it 'cannot impersonate target user if current user does not satisfy all requirements'do
      allow(user1).to receive_message_chain("role.super_admin?"){false}
      allow(user1).to receive_message_chain("role.ta?"){false}
      expect(user1.can_impersonate?(user)).to be false
    end
  end

  describe '#is_recursively_parent_of' do
    context 'when the parent of target user (user) is nil' do

  it 'returns false'
    end

    context 'when the parent of target user (user) is current user (user1)' do
      it 'returns true'
    end

    context 'when the parent of target user (user) is not current user (user1), but super admin (user2)' do
      it 'returns false'
    end
  end

  describe '#get_user_list' do
    context 'when current user is super admin' do
      it 'fetches all users' do
        user_list=double.as_null_object
        allow(user).to receive_message_chain("role.super_admin?"){ true }
        allow(User).to receive_message_chain("all.find_each").and_yield(user1).and_yield(user2)
        allow(user).to receive_message_chain("role.instructor?"){ false }
        allow(user).to receive_message_chain("role.ta?"){false}
        User.all.find_each do |user|
          user_list<<user
        end
        user.get_user_list
        end
      end


    context 'when current user is an instructor' do
      before(:each) do
        course = Course.new
        assignment = Assignment.new
      end
      it 'fetches all users in his/her course/assignment' do
        user_list = double
        course = double
        assignment = double
        allow(user).to receive_message_chain("role.super_admin?"){ false }
        allow(user).to receive_message_chain("role.instructor?"){ true }
        allow(Course).to receive_message_chain(:where,:find_each).and_yield(course)
        allow(course).to receive(:get_participants).and_return(user1)
        allow(Assignment).to receive_message_chain(:where,:find_each).and_yield(assignment)
        allow(assignment).to receive(:participants).and_return(user2)
        allow_any_instance_of(User).to receive(:empty?).and_return(false)
        allow_any_instance_of(User).to receive(:each).and_yield(user1)
        allow_any_instance_of(User).to receive(:user).and_return(user1)
        allow_any_instance_of(User).to receive_message_chain(:role,:hasAllPrivilegesOf).and_return(true)
        allow(user).to receive_message_chain("role.ta?"){false}
        expect(user.get_user_list).to eq ([user1])
      end
    end

    context 'when current user is a TA' do
      it 'fetches all users in his/her courses'
    end
  end

  describe '#super_admin?' do
    it 'returns ture if role name is Super-Administrator' do
      allow(user).to receive_message_chain("role.name"){'Super-Administrator'}
      expect(user.super_admin?).to be_truthy
    end

    it 'returns false if role name is not Super-Administrator' do
      allow(user).to receive_message_chain("role.name"){'CAt'}
      expect(user.super_admin?).to be_falsey
    end
  end

  describe '#is_creator_of?' do
    it 'returns true of current user (user) is the creator of target user (user1)' do
      allow(user1).to receive(:creator).and_return(user)
      expect(user.is_creator_of?(user1)).to be true
    end

    it 'returns false of current user (user) is not the creator of target user (user1)' do
      allow(user1).to receive(:creator).and_return(user2)
      expect(user.is_creator_of?(user1)).to be false
      expect(user2.is_creator_of?(user1)).to be true

    end
  end

  describe '.import' do
    it 'raises error if import column does not equal to 3'

    it 'updates an existing user with info from impor file'
  end

  describe '.yesorno' do
    it 'returns yes when input is true'

    it 'returns no when input is false'

    it 'returns empty string when input is other content'
  end

  describe '.find_by_login' do
    context 'when user\'s email is stored in DB' do
      it 'finds user by email'
    end

    context 'when user\'s email is not stored in DB' do
      it 'finds user by email if the local part of email is the same as username'
    end
  end

  describe '#get_instructor' do
    it 'gets the instructor id'
  end

  describe '#instructor_id' do
    it 'returns id when role of current user is a super admin'

    it 'returns id when role of current user is an Administrator'

    it 'returns id when role of current user is an Instructor'

    it 'returns instructor_id when role of current user is a TA'

    it 'raise an error when role of current user is other type'
  end

  describe '.export' do
    it 'exports all information setting in options'

    it 'exports only personal_details'

    it 'exports only current role and parent'

    it 'exports only email_options'

    it 'exports only handle'
  end

  describe '.export_fields' do
    it 'exports all information setting in options'

    it 'exports only personal_details'

    it 'exports only current role and parent'

    it 'exports only email_options'

    it 'exports only handle'
  end

  describe '.from_params' do
    it 'returns user by user_id fetching from params'

    it 'returns user by user name fetching from params'

    it 'raises an error when Expertiza cannot find user'
  end

  describe '#is_teaching_assistant_for?' do
    it 'returns false if current user is not a TA' do
      allow(user1).to receive_message_chain("role.ta?"){ false }
      expect(user1.is_teaching_assistant_for?(user)).to be_falsey
    end

    it 'returns false if current user is a TA, but target user is not a student'do
      allow(user1).to receive_message_chain("role.ta?"){true }
      allow(user).to receive_message_chain("role.name").and_return('teacher')
      expect(user1.is_teaching_assistant_for?(user)).to be_falsey
    end

    it 'returns true if current user is a TA of target user'
  end

  describe '#is_teaching_assistant?' do
    it 'returns true if current user is a TA' do
      allow(user).to receive_message_chain("role.ta?"){ true }
      expect(user.is_teaching_assistant?).to be true
    end

    it 'returns false if current user is not a TA' do
      allow(user).to receive_message_chain("role.ta?"){ false }
      expect(user.is_teaching_assistant?).to be_falsey
    end
  end
end
